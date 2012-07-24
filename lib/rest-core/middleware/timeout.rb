
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
      yield(env.merge(TIMER =>
        EventMachineTimer.new(timeout(env), timeout_error)))
    else
      ::Timeout.timeout(timeout(env)){ yield(env) }
    end
  end

  def timeout_error
    ::Timeout::Error.new('execution expired')
  end

  autoload :EventMachineTimer,
    'rest-core/middleware/timeout/eventmachine_timer'
end
