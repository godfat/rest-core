
require 'rest-core/middleware'

class RestCore::ErrorHandler
  def self.members; [:error_handler]; end
  include RestCore::Middleware

  def call env
    app.call(handle(env)){ |response| yield(handle(response)) }
  end

  def handle env
    if error_handler(env) && !(env[FAIL] || []).empty?
      error_handler(env).call(env)
    else
      env
    end
  end
end
