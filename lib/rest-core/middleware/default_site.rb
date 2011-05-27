
require 'rest-core/middleware'

class RestCore::DefaultSite
  def self.members; [:site]; end
  include RestCore::Middleware

  def call env
    if env[REQUEST_PATH].start_with?('http')
      app.call(env)
    else
      app.call(env.merge(REQUEST_PATH =>
        "#{site(env)}#{env[REQUEST_PATH]}"))
    end
  end
end
