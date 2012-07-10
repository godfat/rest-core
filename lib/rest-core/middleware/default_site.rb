
require 'rest-core/middleware'

class RestCore::DefaultSite
  def self.members; [:site]; end
  include RestCore::Middleware

  def call env, &k
    path = if env[REQUEST_PATH].to_s.start_with?('http')
             env[REQUEST_PATH]
           else
             "#{site(env)}#{env[REQUEST_PATH]}"
           end

    app.call(env.merge(REQUEST_PATH => path), &k)
  end
end
