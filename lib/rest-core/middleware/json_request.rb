require 'multi_json'
require 'rest-core/middleware'
require 'rest-core/patch/multi_json'

# This middleware converts query/payload to json format.
#
# For more information, see this:
# http://www.digitalhobbit.com/2008/05/25/rails-21-and-incoming-json-requests/
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
