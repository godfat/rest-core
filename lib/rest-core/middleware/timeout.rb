
require 'timeout'

require 'rest-core/middleware'

module RestCore
  class Timeout
    def self.members; [:timeout]; end
    include Middleware

    def call env, &k
      return app.call(env, &k) if env[DRY] || timeout(env) == 0
      process(env, &k)
    end

    def process env, &k
      timer = PromisePool::Timer.new(timeout(env), timeout_error)
      app.call(env.merge(TIMER => timer), &k)
    rescue Exception
      timer.cancel
      raise
    end

    def timeout_error
      ::Timeout::Error.new('execution expired')
    end
  end
end
