
require 'rest-core/middleware'

module RestCore
  class DefaultSite
    def self.members; [:site]; end
    include Middleware

    def call env, &k
      path = if env[REQUEST_PATH].to_s.include?('://')
               env[REQUEST_PATH]
             else
               File.join(site(env).to_s, env[REQUEST_PATH].to_s)
             end

      app.call(env.merge(REQUEST_PATH => path), &k)
    end
  end
end
