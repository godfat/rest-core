
require 'rest-core/middleware'
require 'rest-core/util/json'

class RestCore::JsonRequest
  def self.members; [:json_request]; end
  include RestCore::Middleware

  JSON_REQUEST_HEADER = {'Content-Type' => 'application/json'}.freeze
  JSON_REQUEST_METHOD = [:post, :put, :patch]

  def call env, &k
    return app.call(env, &k) unless json_request(env)
    return app.call(env, &k) unless
      JSON_REQUEST_METHOD.include?(env[REQUEST_METHOD])

    app.call(env.merge(
      REQUEST_HEADERS => JSON_REQUEST_HEADER.merge(env[REQUEST_HEADERS]||{}),
      REQUEST_PAYLOAD => Json.encode(env[REQUEST_PAYLOAD])              ), &k)
  end
end
