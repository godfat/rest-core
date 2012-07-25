
require 'rest-core/middleware'

class RestCore::ErrorAsyncPass
  include RestCore::Middleware

  def call env
    app.call(env){ |res|
      if res[RC::ASYNC] && !(res[RC::FAIL] || []).empty?
        yield(res.merge(RC::RESPONSE_BODY => res[RC::FAIL]))
      else
        yield(res)
      end
    }
  end
end
