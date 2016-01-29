
require 'rest-core/middleware'

module RestCore
  class DefaultQuery
    def self.members; [:query]; end
    include Middleware
    def call env, &k
      q = merge_hash(@query, query(env), env[REQUEST_QUERY])
      app.call(env.merge(REQUEST_QUERY => q), &k)
    end
  end
end
