
require 'rest-core/middleware'

class RestCore::DefaultQuery
  def self.members; [:query]; end
  include RestCore::Middleware

  def initialize *args
    super
    @query ||= {}
  end

  def call env, &k
    defaults = string_keys(@query).merge(string_keys(query(env)))

    app.call(env.merge(REQUEST_QUERY =>
      defaults.merge(env[REQUEST_QUERY])), &k)
  end
end
