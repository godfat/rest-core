
module RestCore
  class ErrorDetector
    def self.members; [:error_detector]; end
    include Middleware

    def call env
      app.call(env){ |response|
        detector = error_detector(env)
        yield(fail(response, detector && detector.call(response)))
      }
    end
  end
end
