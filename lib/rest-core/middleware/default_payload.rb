
require 'rest-core/middleware'

class RestCore::DefaultPayload
  def self.members; [:payload]; end
  include RestCore::Middleware
  def call env, &k
    app.call(env.merge(REQUEST_PAYLOAD =>
      @payload.merge(payload(env)).merge(env[REQUEST_PAYLOAD] || {})), &k)
  end
end
