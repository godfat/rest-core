
require 'rest-core/middleware'

class RestCore::ErrorHandler
  def self.members; [:error_handler]; end
  include RestCore::Middleware

  def call env
    if env[ASYNC]
      app.call(handle(env).merge(ASYNC => lambda{ |response|
        env[ASYNC].call(handle(response))
      }))
    else
      handle(app.call(handle(env)))
    end
  end

  def handle env
    if error_handler(env) && !(env[FAIL] || []).empty?
      error_handler(env).call(env)
    else
      env
    end
  end
end
