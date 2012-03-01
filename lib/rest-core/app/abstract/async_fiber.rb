
require 'rest-core/middleware'

class RestCore::AsyncFiber
  include RestCore::Middleware
  def call env
    if env[ASYNC]
      async.call(env)
    else
      fiber.call(env)
    end
  end
end
