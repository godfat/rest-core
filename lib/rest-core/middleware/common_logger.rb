
require 'rest-core/event'
require 'rest-core/middleware'

class RestCore::CommonLogger
  def self.members; [:log_method]; end
  include RestCore::Middleware

  def call env
    start_time = Time.now
    flush(log(env, Event::Requested.new(Time.now - start_time,
                                        request_uri(app.call(flush(env))))))
  end

  def flush env
    return unless log_method(env)
    (env[LOG] ||= []).each{ |event|
      log_method(env).call("RestCore: #{event}") }
    env.merge(LOG => [])
  end
end
