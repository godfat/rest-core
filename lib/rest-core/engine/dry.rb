
require 'rest-core/middleware'

class RestCore::Dry
  include RestCore::Middleware
  def call env
    yield(env)
  end
end
