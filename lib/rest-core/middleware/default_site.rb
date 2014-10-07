
require 'rest-core/middleware'

class RestCore::DefaultSite
  def self.members; [:site]; end
  include RestCore::Middleware

  def call env, &k
    path = env[REQUEST_PATH].to_s

    unless full_url?(path)
      File.join(site(env).to_s, path)
    end

    app.call(env.merge(REQUEST_PATH => path), &k)
  end

  private

  def full_url?(path)
    path.start_with?('http') || path.start_with?('https')
  end
end
