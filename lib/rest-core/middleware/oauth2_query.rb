
require 'rest-core/middleware'

class RestCore::Oauth2Query
  def self.members; [:access_token, :client_id]; end
  include RestCore::Middleware

  def call env, &k
    if (access_token = access_token(env))

      env[REQUEST_QUERY]['access_token'] || = access_token

    elsif (client_id = client_id(env))

      env[REQUEST_QUERY]['client_id'] ||= client_id
    end

    app.call(env, &k)
  end
end
