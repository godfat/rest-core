
require 'rest-core/middleware'

class RestCore::DefaultHeaders
  def self.members; [:headers]; end
  include RestCore::Middleware
  def call env
    app.call(ask(env))
  end

  def ask env
    env.merge(REQUEST_HEADERS =>
      @headers.merge(headers(env)).merge(env[REQUEST_HEADERS] || {}))
  end
end
