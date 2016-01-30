
require 'rest-core/util/json'

module RestCore
  class JsonRequest
    def self.members; [:json_request]; end
    include Middleware

    JSON_REQUEST_HEADER = {'Content-Type' => 'application/json'}.freeze

    def call env, &k
      return app.call(env, &k) unless json_request(env)
      return app.call(env, &k) unless has_payload?(env)

      headers = env[REQUEST_HEADERS] || {}
      app.call(env.merge(
        REQUEST_HEADERS => JSON_REQUEST_HEADER.merge(headers),
        REQUEST_PAYLOAD => Json.encode(env[REQUEST_PAYLOAD])), &k)
    end
  end
end
