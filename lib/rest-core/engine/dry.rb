
require 'rest-core/middleware'

module RestCore
  class Dry
    include Middleware
    def call env
      yield(env)
    end
  end
end
