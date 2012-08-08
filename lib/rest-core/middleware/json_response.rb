
require 'rest-core/middleware'
require 'rest-core/util/json'

class RestCore::JsonResponse
  def self.members; [:json_response]; end
  include RestCore::Middleware

  def call env, &k
    return app.call(env, &k) if env[DRY]
    app.call(env){ |response|
      yield(process(response))
    }
  end

  def process response
    if json_response(response)
      response.merge(RESPONSE_BODY =>
        Json.decode("[#{response[RESPONSE_BODY]}]").first)
        # [this].first is not needed for yajl-ruby
    else
      response
    end
  rescue Json.const_get(:ParseError) => error
    fail(response, error)
  end
end
