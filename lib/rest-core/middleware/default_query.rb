
require 'rest-core/middleware'

class RestCore::DefaultQuery
  def self.members; [:query]; end
  include RestCore::Middleware
  def call env, &k
    q = merge_hash(@query, query(env), env[REQUEST_QUERY])
    app.call(env.merge(REQUEST_QUERY => q), &k)
  end
end
