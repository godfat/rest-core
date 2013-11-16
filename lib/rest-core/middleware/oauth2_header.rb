
require 'rest-core/middleware'

class RestCore::Oauth2Header
  def self.members; [:access_token_type, :access_token]; end
  include RestCore::Middleware

  def call env, &k
    start_time = Time.now

    if (access_token = access_token(env))
      access_token_type = access_token_type env

      env[REQUEST_HEADERS]['Authorization'] ||=
        if access_token_type == 'token'
          %{Token token="#{access_token}"}
        else
          "#{access_token_type} #{access_token}"
        end
    end

    event = Event::WithHeader.new(Time.now - start_time,
              "Authorization: #{env[REQUEST_HEADERS]['Authorization']}") if access_token

    app.call(log(env, event), &k)
  end
end
