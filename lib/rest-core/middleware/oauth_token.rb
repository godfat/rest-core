
require 'rest-core/middleware'

class RestCore::OauthToken
  def self.members; [:oauth_token_name, :oauth_token]; end
  include RestCore::Middleware

  def call env
    local = if oauth_token(env)
              env.merge(REQUEST_QUERY => (env[REQUEST_QUERY] || {}).merge(
                oauth_token_name(env) => oauth_token(env)))
            else
              env
            end

    app.call(local)
  end
end
