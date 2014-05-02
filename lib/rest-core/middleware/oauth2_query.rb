
require 'rest-core/middleware'

# http://tools.ietf.org/html/rfc6749
class RestCore::Oauth2Query
  def self.members; [:access_token]; end
  include RestCore::Middleware

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
