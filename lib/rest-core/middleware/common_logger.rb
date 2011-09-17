
require 'rest-core/event'
require 'rest-core/middleware'

class RestCore::CommonLogger
  def self.members; [:log_method]; end
  include RestCore::Middleware

  def call env
    start_time = Time.now
    response = app.call(flushed = flush(env))
    flush(log(response, log_request(start_time, response)))
  rescue
    flush(log(flushed, log_request(start_time, flushed)))
    raise
  end

  def flush env
    return env if !log_method(env) || env[DRY]
    (env[LOG] || []).compact.
      each{ |obj| log_method(env).call("RestCore: #{obj}") }
    env.merge(LOG => [])
  end

  def log_request start_time, response
    Event::Requested.new(Time.now - start_time, request_uri(response))
  end
end
