
require 'rest-core/middleware'

class RestCore::ErrorDetector
  def self.members; [:error_detector]; end
  include RestCore::Middleware

  def call env
    response = app.call(env)
    if error = error_detector(env).call(response)
      fail(response, error)
    else
      response
    end
  end
end
