
require 'rest-core/middleware'

class RestCore::ErrorHandler
  def self.members; [:error_handler]; end
  include RestCore::Middleware

  def call env
    handle(app.call(handle(env)))
  end

  def handle env
    if error_handler(env) && !(env[FAIL] || []).empty?
      error_handler(env).call(env)
    else
      env
    end
  end
end
