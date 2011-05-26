
require 'rest-core/middleware'

class RestCore::DefaultSite
  def self.members; [:site]; end
  include RestCore::Middleware

  def call env
    if env[REQUEST_URI].start_with?('http')
      app.call(env)
    else
      app.call(env.merge(REQUEST_URI =>
        "#{site(env)}#{env[REQUEST_URI]}"))
    end
  end
end
