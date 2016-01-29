
require 'rest-core/middleware'
require 'rest-core/util/parse_query'

module RestCore
  class QueryResponse
    def self.members; [:query_response]; end
    include Middleware

    QUERY_RESPONSE_HEADER =
      {'Accept' => 'application/x-www-form-urlencoded'}.freeze

    def call env, &k
      return app.call(env, &k) if env[DRY]
      return app.call(env, &k) unless query_response(env)

      headers = QUERY_RESPONSE_HEADER.merge(env[REQUEST_HEADERS]||{})
      app.call(env.merge(REQUEST_HEADERS => headers)) do |response|
        body = ParseQuery.parse_query(response[RESPONSE_BODY])
        yield(response.merge(RESPONSE_BODY => body))
      end
    end
  end
end
