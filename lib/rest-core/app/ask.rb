
require 'rest-core/middleware'

require 'restclient'

class RestCore::Ask
  include RestCore::Middleware
  def call env
    env
  end
end
