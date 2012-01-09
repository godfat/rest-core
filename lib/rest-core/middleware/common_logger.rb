
require 'rest-core/event'
require 'rest-core/middleware'

class RestCore::CommonLogger
  def self.members; [:log_method]; end
  include RestCore::Middleware

  def call env
    start_time = Time.now
    flushed = flush(env)
    if env[ASYNC]
      app.call(flushed.merge(ASYNC => lambda{ |response|
        env[ASYNC].call(process(response, start_time))
      }))
    else
      response = app.call(flushed)
      process(response, start_time)
    end
  rescue
    process(flushed, start_time)
    raise
  end

  def process response, start_time
    flush(log(response, log_request(start_time, response)))
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
