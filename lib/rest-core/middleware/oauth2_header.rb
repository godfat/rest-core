
require 'rest-core/event'
require 'rest-core/middleware'

module RestCore
  # http://tools.ietf.org/html/rfc6749
  class Oauth2Header
    def self.members; [:access_token_type, :access_token]; end
    include Middleware

    def call env, &k
      start_time = Time.now
      headers    = build_headers(env)
      auth       = headers['Authorization']
      event      = Event::WithHeader.new(Time.now - start_time,
                     "Authorization: #{auth}") if auth

      app.call(log(env.merge(REQUEST_HEADERS => headers), event), &k)
    end

    def build_headers env
      auth = case token = access_token(env)
             when String
               token
             when Hash
              token.map{ |(k, v)| "#{k}=\"#{v}\"" }.join(', ')
             end

      if auth
        {'Authorization' => "#{access_token_type(env)} #{auth}"}
      else
        {}
      end.merge(env[REQUEST_HEADERS])
    end
  end
end
