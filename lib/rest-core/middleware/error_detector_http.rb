
require 'rest-core/middleware/error_detector'

class RestCore::ErrorDetectorHttp < RestCore::ErrorDetector
  def self.members; [:error_detector]; end
  include RestCore::Middleware

  def initialize app
    super(app, lambda{ |env| (env[RESPONSE_STATUS] || 200) / 100 != 2 })
  end
end
