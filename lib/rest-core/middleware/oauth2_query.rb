
require 'rest-core/middleware'

module RestCore
  # http://tools.ietf.org/html/rfc6749
  class Oauth2Query
    def self.members; [:access_token]; end
    include Middleware

    def call env, &k
      local = if access_token(env)
                env.merge(REQUEST_QUERY =>
                            {'access_token' => access_token(env)}.
                             merge(env[REQUEST_QUERY]))
              else
                env
              end

      app.call(local, &k)
    end
  end
end
