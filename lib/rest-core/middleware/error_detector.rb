
require 'rest-core/middleware'

class RestCore::ErrorDetector
  def self.members; [:error_detector]; end
  include RestCore::Middleware

  def call env
    if env[ASYNC]
      app.call(env.merge(ASYNC => lambda{ |response|
        env[ASYNC].call(process(env, response))
      }))
    else
      process(env, app.call(env))
    end
  end

  def process env, response
    if error = error_detector(env).call(response)
      fail(response, error)
    else
      response
    end
  end
end
