
require 'rest-core/middleware'

class RestCore::DefaultHeaders
  def self.members; [:headers]; end
  include RestCore::Middleware
  def call env, &k
    app.call(env.merge(REQUEST_HEADERS =>
      @headers.merge(headers(env)).merge(env[REQUEST_HEADERS])), &k)
  end
end
