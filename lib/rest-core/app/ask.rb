
require 'rest-core/middleware'

class RestCore::Ask
  include RestCore::Middleware
  def call env
    env
  end
end
