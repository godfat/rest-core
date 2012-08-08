
require 'rest-core/middleware'

class RestCore::DefaultPayload
  def self.members; [:payload]; end
  include RestCore::Middleware

  def initialize *args
    super
    @payload ||= {}
  end

  def call env, &k
    defaults = string_keys(@payload).merge(string_keys(payload(env)))

    app.call(env.merge(REQUEST_PAYLOAD =>
      defaults.merge(env[REQUEST_PAYLOAD] || {})), &k)
  end
end
