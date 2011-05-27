
require 'rest-core/middleware'

class RestCore::DefaultSite
  def self.members; [:site]; end
  include RestCore::Middleware

  def call env
    app.call(ask(env))
  end

  def ask env
    if env[REQUEST_PATH].to_s.start_with?('http')
      env
    else
      env.merge(REQUEST_PATH => "#{site(env)}#{env[REQUEST_PATH]}")
    end
  end
end
