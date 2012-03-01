
require 'rest-core/app/abstract/async_fiber'
require 'rest-core/app/coolio-async'
require 'rest-core/app/coolio-fiber'

class RestCore::Coolio < RestCore::AsyncFiber
  def async; @async ||= CoolioAsync.new; end
  def fiber; @fiber ||= CoolioFiber.new; end
end
