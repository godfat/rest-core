
require 'rest-core/middleware'
require 'rest-core/util/clash'

module RestCore
  class ClashResponse
    def self.members; [:clash_response]; end
    include Middleware

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
end
