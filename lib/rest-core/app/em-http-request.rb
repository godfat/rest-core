
require 'rest-core/app/abstract/async_fiber'
require 'rest-core/app/em-http-request-async'
require 'rest-core/app/em-http-request-fiber'

class RestCore::EmHttpRequest < RestCore::AsyncFiber
  def initialize
    super(EmHttpRequestAsync.new, EmHttpRequestFiber.new)
  end
end
