
require 'rest-core/middleware'

require 'timeout'

class RestCore::Timeout
  def self.members; [:timeout]; end
  include RestCore::Middleware

  def call env
    ::Timeout.timeout(timeout(env)){ app.call(env) }
  end
end
