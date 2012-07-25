
require 'rest-core/middleware'

class RestCore::ErrorHandler
  def self.members; [:error_handler]; end
  include RestCore::Middleware

  def call env
    app.call(env){ |res|
      yield(if res[FAIL] && res[FAIL].empty? # no errors at all
              res
            else
              error = if error_handler(res)
                        error_handler(res).call(res)
                      else
                        nil
                      end
              if res[ASYNC] # in async mode, we report all errors
                err = [res[FAIL], error].flatten.compact
                res.merge(RESPONSE_BODY => err, FAIL => err)
              # if user provides an exception,
              elsif error.kind_of?(Exception)
                raise error # raise it
              else          # otherwise return it
                error
              end
            end)}
  end
end
