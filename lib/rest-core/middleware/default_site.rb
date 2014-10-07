
require 'rest-core/middleware'

class RestCore::DefaultSite
  def self.members; [:site]; end
  include RestCore::Middleware

  def call env, &k
    path = if full_url?(env[REQUEST_PATH])
             env[REQUEST_PATH]
           else
             File.join(site(env), env[REQUEST_PATH])
           end

    app.call(env.merge(REQUEST_PATH => path), &k)
  end

  private

  def full_url?(path)
    path = path.to_s
    path.start_with?('http') || path.start_with?('https')
  end
end
