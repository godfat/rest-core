
module RestCore
  class DefaultPayload
    def self.members; [:payload]; end
    include Middleware
    def call env, &k
      p = merge_hash(@payload, payload(env), env[REQUEST_PAYLOAD])
      app.call(env.merge(REQUEST_PAYLOAD => p), &k)
    end
  end
end
