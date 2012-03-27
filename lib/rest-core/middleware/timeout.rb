
require 'rest-core/middleware'

require 'timeout'

class RestCore::Timeout
  def self.members; [:timeout]; end
  include RestCore::Middleware

  def call env
    return app.call(env) if env[DRY] || timeout(env) == 0
    monitor(env){ |e| app.call(e) }
  end

  def monitor env
    class_name = case name = run.class.to_s
                 when /Auto/
                   run.http_client.class.to_s
                 else
                   name
                 end

    case class_name
    when /EmHttpRequest|Coolio/
      if root_fiber? && env[ASYNC]
        yield(env.merge(TIMER => timeout_with_callback(env, class_name)))
      else
        yield(env.merge(TIMER => timeout_with_resume(  env, class_name)))
      end
    else
      ::Timeout.timeout(timeout(env)){ yield(env) }
    end
  end

  def root_fiber?
    if RestCore.const_defined?(:RootFiber)
      RootFiber == Fiber.current
    else
      true
    end
  end

  def timeout_with_callback env, class_name
    case class_name
    when /EmHttpRequest/
      EventMachineTimer.new(timeout(env), timeout_error)
    when /Coolio/
      timer = CoolioTimer.new(timeout(env))
      timer.error = timeout_error
      timer.attach(::Coolio::Loop.default)
      timer
    else
      raise "BUG: #{run} is not supported"
    end
  end

  def timeout_with_resume env, class_name
    case class_name
    when /EmHttpRequest/
      f = Fiber.current
      EventMachineTimer.new(timeout(env), error = timeout_error){
        f.resume(error) if f.alive?
      }

    when /Coolio/
      f = Fiber.current
      timer = CoolioTimer.new(timeout(env))
      error = timer.error = timeout_error
      timer.on_timer{ f.resume(error) if f.alive? }
      timer.attach(::Coolio::Loop.default)
      timer

    else
      raise "BUG: #{run} is not supported"
    end
  end

  def timeout_error
    ::Timeout::Error.new('execution expired')
  end

  autoload :EventMachineTimer,
    'rest-core/middleware/timeout/eventmachine_timer'
  autoload       :CoolioTimer,
    'rest-core/middleware/timeout/coolio_timer'
end
