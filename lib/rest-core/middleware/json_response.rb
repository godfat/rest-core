
require 'rest-core/middleware'
require 'rest-core/util/json'

class RestCore::JsonResponse
  def self.members; [:json_response]; end
  include RestCore::Middleware

  JSON_RESPONSE_HEADER = {'Accept' => 'application/json'}.freeze

  def call env, &k
    return app.call(env, &k) if env[DRY]
    return app.call(env, &k) unless json_response(env)

    app.call(env.merge(REQUEST_HEADERS =>
      JSON_RESPONSE_HEADER.merge(env[REQUEST_HEADERS]||{}))){ |response|
        yield(process(response))
      }
  end

  def process response
    response.merge(RESPONSE_BODY =>
      Json.decode("[#{response[RESPONSE_BODY]}]").first)
      # [this].first is not needed for yajl-ruby
  rescue Json.const_get(:ParseError) => error
    fail(response, error)
  end
end
