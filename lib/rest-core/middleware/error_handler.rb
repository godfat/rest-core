
require 'rest-core/middleware'

class RestCore::ErrorHandler
  def self.members; [:error_handler]; end
  include RestCore::Middleware

  def call env
    app.call(env){ |res|
      yield(if (res[FAIL] || []).empty? # no errors at all
              res
            else
              # if there's an exception, hand it over
              if err = res[FAIL].find{ |e| e.kind_of?(Exception) }
                process(res, err)

              elsif h = error_handler(res)
                # if the user provides an exception, hand it over
                if (err = h.call(res)).kind_of?(Exception)
                  process(res, err)

                else # otherwise we report all of them
                  res.merge(FAIL => [res[FAIL], err].flatten.compact)

                end
              else # no exceptions at all, then do nothing
                res
              end
            end)}
  end

  def process res, err
    RC::Promise.set_backtrace(err)
    if res[ASYNC]
      if res[HIJACK]
        res.merge(RESPONSE_SOCKET => err)
      else
        res.merge(RESPONSE_BODY => err)
      end
    else
      raise err
    end
  end
end
