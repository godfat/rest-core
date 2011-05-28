
require 'rest-core/event'
require 'rest-core/middleware'

class RestCore::CommonLogger
  def self.members; [:log_method]; end
  include RestCore::Middleware

  def call env
    flush(env)
    start_time = Time.now
    response = app.call(env)
    log(env, Event::Requested.new(Time.now - start_time, request_uri(env)))
    flush(response)
    response
  end

  def flush env
    return unless log_method(env)
    (env['log'] ||= []).each{ |event|
      log_method(env).call("RestCore: #{event}") }
    env['log'].clear
    env
  end
end
