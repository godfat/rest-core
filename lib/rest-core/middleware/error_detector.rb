
require 'rest-core/middleware'

class RestCore::ErrorDetector
  def self.members; [:error_detector]; end
  include RestCore::Middleware

  def call env
    response = app.call(env)
    if response[RESPONSE_BODY].kind_of?(Hash) &&
       error_detector(env).call(response)

      app.fail(response)
    end
    response
  end
end
