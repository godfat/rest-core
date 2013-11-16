
require 'rest-core/middleware'

class RestCore::ErrorDetector
  def self.members; [:error_detector]; end
  include RestCore::Middleware

  def call env
    app.call(env){ |response|
      detector = error_detector(env)
      yield(fail(response, detector && detector.call(response)))
    }
  end
end
