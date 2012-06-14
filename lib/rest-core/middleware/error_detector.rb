
require 'rest-core/middleware'

class RestCore::ErrorDetector
  def self.members; [:error_detector]; end
  include RestCore::Middleware

  def call env
    app.call(env){ |response|
      detector = error_detector(env)
      yield(
        if error = (detector && detector.call(response))
          fail(response, error)
        else
          response
        end)
    }
  end
end
