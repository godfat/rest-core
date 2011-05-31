
require 'rest-core/middleware'

class RestCore::OauthToken
  def self.members; [:oauth_token_name, :oauth_token]; end
  include RestCore::Middleware

  def call env
    app.call(env.merge(REQUEST_QUERY => env[REQUEST_QUERY].merge(
      oauth_token_name(env) => oauth_token(env))))
  end
end
