
require 'rest-core/middleware'

class RestCore::ErrorHandler
  def self.members; [:error_handler]; end
  include RestCore::Middleware

  def fail env
    app.fail(env)
    error_handler(env).call(env) if error_handler(env)
  end
end
