
require 'rest-core/middleware'
require 'rest-core/util/clash'

class RestCore::ClashResponse
  def self.members; [:clash_response]; end
  include RestCore::Middleware

  def call env, &k
    return app.call(env, &k) if env[DRY]
    return app.call(env, &k) unless clash_response(env)

    app.call(env){ |res|
      if res[RESPONSE_BODY].kind_of?(Hash)
        yield(res.merge(RESPONSE_BODY => Clash.new(res[RESPONSE_BODY])))
      else
        yield(res)
      end
    }
  end
end
