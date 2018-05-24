
require 'rest-core/util/json'

module RestCore
  class JsonResponse
    def self.members; [:json_response]; end
    include Middleware

    class ParseError < Json.const_get(:ParseError)
      attr_reader :cause, :body
      def initialize cause, body
        msg = cause.message.force_encoding('utf-8')
        super("#{msg}\nOriginal text: #{body}")
        @cause, @body = cause, body
      end
    end

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
      body = response[RESPONSE_BODY]
      json = if body.kind_of?(String)
               Json.normalize(body)
             elsif body.nil?
               Json.encode(nil)
             else
               # Yajl supports streaming, so let's pass it directly to make
               # it possible to do streaming here. Although indeed we should
               # use RESPONSE_SOCKET in this case, but doing that could
               # introduce some incompatibility which I don't want to take
               # care of for now.
               body
             end

      response.merge(RESPONSE_BODY => Json.decode(json))
    rescue Json.const_get(:ParseError) => error
      fail(response, ParseError.new(error, body))
    end
  end
end
