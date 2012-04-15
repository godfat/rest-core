require 'multi_json'
require 'rest-core/middleware'
require 'rest-core/patch/multi_json'

class RestCore::JsonRequest
  def self.members; [:json_request]; end
  include RestCore::Middleware

  JSON_REQUEST_HEADER = {'Content-Type' => 'application/json'}.freeze

  def call env
    payload = env[REQUEST_METHOD] == :get ?
              env[REQUEST_QUERY]          :
              env[REQUEST_PAYLOAD]
    env = env.merge(
      REQUEST_HEADERS => JSON_REQUEST_HEADER.merge(env[REQUEST_HEADERS]),
      REQUEST_PAYLOAD => MultiJson.dump(payload || {}),
      REQUEST_QUERY   => nil)
    app.call(env)
  end
end
