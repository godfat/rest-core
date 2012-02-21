
require 'rest-core/middleware'

require 'timeout'

class RestCore::Timeout
  def self.members; [:timeout]; end
  include RestCore::Middleware

  def call env
    monitor(env){ |e| app.call(e) }
  end

  def monitor env
    if root_fiber?
      if event_engine
        yield(env.merge(TIMER => timeout_with_callback(env)))
      else
        ::Timeout.timeout(timeout(env)){ yield(env) }
      end
    else
      yield(env.merge(TIMER => timeout_with_resume(env)))
    end
  end

  def root_fiber?
    RestCore.const_defined?(:RootFiber) && RootFiber == Fiber.current
  end

  def event_engine
    Object.const_defined?(:Coolio)    ||
    Object.const_defined?(:EventMachine)
  end

  def timeout_with_callback env
    if Object.const_defined?(:Coolio)
      timer = CoolioTimer.new(timeout(env))
      timer.error = timeout_error
      timer.attach(::Coolio::Loop.default)
      timer
    elsif Object.const_defined?(:EventMachine)
      EventMachineTimer.new(timeout(env), timeout_error)
    end
  end

  def timeout_with_resume env
    if Object.const_defined?(:Coolio)
      f = Fiber.current
      timer = CoolioTimer.new(timeout(env))
      error = timer.error = timeout_error
      timer.on_timer{ f.resume(error) if f.alive? }
      timer.attach(::Coolio::Loop.default)
      timer

    elsif Object.const_defined?(:EventMachine)
      f = Fiber.current
      EventMachineTimer.new(timeout(env), error = timeout_error){
        f.resume(error) if f.alive?
      }
    end
  end

  def timeout_error
    ::Timeout::Error.new('execution expired')
  end

  autoload       :CoolioTimer,
    'rest-core/middleware/timeout/coolio_timer'
  autoload :EventMachineTimer,
    'rest-core/middleware/timeout/eventmachine_timer'
end
