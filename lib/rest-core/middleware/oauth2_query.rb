
require 'rest-core/middleware'

class RestCore::Oauth2Query
  def self.members; [:access_token]; end
  include RestCore::Middleware

  def call env
    local = if access_token(env)
              env.merge(REQUEST_QUERY =>
                          {'access_token' => access_token(env)}.
                           merge(env[REQUEST_QUERY] || {}))
            else
              env
            end

    app.call(local, &id)
  end
end
