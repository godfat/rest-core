
require 'rest-core/middleware'

class RestCore::AuthBasic
  def self.members; [:username, :password]; end
  include RestCore::Middleware

  def call env, &k
    if username(env)
      if password(env)
        app.call(env.merge(REQUEST_HEADERS =>
          auth_basic_header(env).merge(env[REQUEST_HEADERS])), &k)
      else
        app.call(log(env, "AuthBasic: username provided: #{username(env)}," \
                          " but password is missing."), &k)
      end
    elsif password(env)
      app.call(log(env, "AuthBasic: password provided: #{password(env)}," \
                        " but username is missing."), &k)
    else
      app.call(env, &k)
    end
  end

  def auth_basic_header env
    {'Authorization' =>
       "Basic #{["#{username(env)}:#{password(env)}"].pack('m0')}"}
  end
end
