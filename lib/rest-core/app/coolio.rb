
require 'rest-core/app/abstract/async_fiber'
require 'rest-core/app/coolio-async'
require 'rest-core/app/coolio-fiber'

class RestCore::Coolio < RestCore::AsyncFiber
  def initialize
    super(CoolioAsync.new, CoolioFiber.new)
  end
end
