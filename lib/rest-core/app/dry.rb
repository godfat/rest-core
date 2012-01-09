
require 'rest-core/middleware'

class RestCore::Dry
  include RestCore::Middleware
  def call env
    env[ASYNC].call(env) if env[ASYNC]
    env
  end
end
