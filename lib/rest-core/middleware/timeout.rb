
require 'rest-core/middleware'

require 'timeout'

class RestCore::Timeout
  def self.members; [:timeout]; end
  include RestCore::Middleware

  def call env, &k
    return app.call(env, &k) if env[DRY] || timeout(env) == 0
    monitor(env){ |e| app.call(e, &k) }
  end

  def monitor env
    class_name = case name = run.class.to_s
                 when /Auto/
                   run.http_client.class.to_s
                 else
                   name
                 end

    case class_name
    when /EmHttpRequest/
      if env[ASYNC]
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
        # no need to check if the fiber is already resumed or not,
        # because monitor should have already handled this in the
        # case of fibers
      }

    else
      raise "BUG: #{run} is not supported"
    end
  end

  def timeout_error
    ::Timeout::Error.new('execution expired')
  end

  autoload :EventMachineTimer,
    'rest-core/middleware/timeout/eventmachine_timer'
end
