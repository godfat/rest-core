
require 'rest-core/middleware/error_detector'

module RestCore
  class ErrorDetectorHttp < RestCore::ErrorDetector
    def initialize app, detector=nil
      super(app, detector ||
                 lambda{ |env| (env[RESPONSE_STATUS] || 200) / 100 >= 4 })
    end
  end
end
