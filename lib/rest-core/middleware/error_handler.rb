
require 'rest-core/middleware'

class RestCore::ErrorHandler
  def self.members; [:error_handler]; end
  include RestCore::Middleware

  def call env
    app.call(env){ |res|
      yield(if (res[FAIL] || []).empty? || !(h = error_handler(res))
              res
            else
              fail(res, h.call(res))
            end)}
  end
end
