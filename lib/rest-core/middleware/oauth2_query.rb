
require 'rest-core/middleware'

class RestCore::Oauth2Query
  def self.members; [:oauth_token_name, :oauth_token]; end
  include RestCore::Middleware

  def call env
    local = if oauth_token(env)
              env.merge(REQUEST_QUERY =>
                          {oauth_token_name(env) => oauth_token(env)}.
                           merge(env[REQUEST_QUERY] || {}))
            else
              env
            end

    app.call(local)
  end
end
