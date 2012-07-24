
require 'rest-core/middleware'

class RestCore::Oauth2Header
  def self.members; [:access_token_type, :access_token]; end
  include RestCore::Middleware

  def call env, &k
    start_time = Time.now
    headers = {'Authorization' =>
                 "#{access_token_type(env)} #{access_token(env)}"}.
                merge(env[REQUEST_HEADERS] || {}) if access_token(env)

    event = Event::WithHeader.new(Time.now - start_time,
              "Authorization: #{headers['Authorization']}") if headers

    app.call(log(env.merge(REQUEST_HEADERS => headers ||
                                              env[REQUEST_HEADERS]), event),
             &k)
  end
end
