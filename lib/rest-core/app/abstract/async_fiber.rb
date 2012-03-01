
require 'rest-core/middleware'

class RestCore::AsyncFiber
  include RestCore::Middleware
  def initialize async, fiber
    @async, @fiber = async, fiber
  end

  def call env
    if env[ASYNC]
      async.call(env)
    else
      fiber.call(env)
    end
  end

  protected
  attr_reader :async, :fiber
end
