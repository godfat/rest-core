
require 'rest-core/middleware'

class RestCore::DefaultQuery
  def self.members; [:query]; end
  include RestCore::Middleware

  def initialize(*args)
    super
    @query ||= {}
  end

  def call env
    app.call(env.merge(REQUEST_QUERY =>
      @query.merge(query(env)).merge(env[REQUEST_QUERY] || {})))
  end
end
