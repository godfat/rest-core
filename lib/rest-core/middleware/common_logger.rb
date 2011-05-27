
require 'rest-core/event'
require 'rest-core/middleware'

class RestCore::CommonLogger
  def self.members; [:log_method]; end
  include RestCore::Middleware

  def call env
    start_time = Time.now
    response = app.call(env)
    log(env.merge('event' =>
      Event::Requested.new(Time.now - start_time, request_uri(env))))
    response
  end

  def log env
    log_method(env).call("DEBUG: #{env['event']}") if log_method(env)
    app.log(env)
  end
end
