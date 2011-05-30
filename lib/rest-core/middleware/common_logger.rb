
require 'rest-core/event'
require 'rest-core/middleware'

class RestCore::CommonLogger
  def self.members; [:log_method]; end
  include RestCore::Middleware

  def call env
    start_time = Time.now
    response = app.call(flush(env))
    flush(log(response, Event::Requested.new(Time.now - start_time,
                                             request_uri(response))))
  end

  def flush env
    return env unless log_method(env)
    (env[LOG] || []).each{ |obj| log_method(env).call("RestCore: #{obj}") }
    env.merge(LOG => [])
  end
end
