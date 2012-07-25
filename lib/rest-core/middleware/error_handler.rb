
require 'rest-core/middleware'

class RestCore::ErrorHandler
  def self.members; [:error_handler]; end
  include RestCore::Middleware

  def call env
    app.call(env){ |res|
      yield(if error_handler(res) && !(res[FAIL] || []).empty?
              error_handler(res).call(res)
            else
              res
            end)}
  end
end
