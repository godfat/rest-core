
require 'rest-core/event'
require 'rest-core/middleware'

class RestCore::CommonLogger
  def self.members; [:log_method]; end
  include RestCore::Middleware

  def call env
    start_time = Time.now
    flushed = flush(env)
    app.call(flushed){ |response|
      yield(process(response, start_time))
    }
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
    Event::Requested.new(Time.now - start_time,
      "#{response[RC::REQUEST_METHOD].to_s.upcase} #{request_uri(response)}")
  end
end
