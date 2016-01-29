
require 'rest-core/middleware'

module RestCore
  class DefaultHeaders
    def self.members; [:headers]; end
    include Middleware
    def call env, &k
      h = merge_hash(@headers, headers(env), env[REQUEST_HEADERS])
      app.call(env.merge(REQUEST_HEADERS => h), &k)
    end
  end
end
