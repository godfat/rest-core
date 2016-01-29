
require 'rest-core/middleware'
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
      # StackExchange returns the problematic BOM! in UTF-8, so we need to
      # strip it or it would break JSON parsers (i.e. yajl-ruby and json)
      body = response[RESPONSE_BODY].to_s.sub(/\A\xEF\xBB\xBF/, '')
      response.merge(RESPONSE_BODY => Json.decode("[#{body}]").first)
      # [this].first is not needed for yajl-ruby
    rescue Json.const_get(:ParseError) => error
      fail(response, ParseError.new(error, body))
    end
  end
end
