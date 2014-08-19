
require 'rest-core/middleware'

class RestCore::DefaultPayload
  def self.members; [:payload]; end
  include RestCore::Middleware
  def call env, &k
    p = if env[REQUEST_PAYLOAD].kind_of?(Hash)
          if payload(env).kind_of?(Hash)
            merge_hash(payload(env), env[REQUEST_PAYLOAD])
          else
            payload(env)
          end
        else
          env[REQUEST_PAYLOAD]
        end
    app.call(env.merge(REQUEST_PAYLOAD => p), &k)
  end
end
