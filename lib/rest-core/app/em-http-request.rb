
require 'rest-core/app/abstract/async_fiber'
require 'rest-core/app/em-http-request-async'
require 'rest-core/app/em-http-request-fiber'

class RestCore::EmHttpRequest < RestCore::AsyncFiber
  def async; @async ||= EmHttpRequestAsync.new; end
  def fiber; @fiber ||= EmHttpRequestFiber.new; end
end
