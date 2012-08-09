
require 'fiber'

class RestCore::Future::FutureFiber < RestCore::Future
  def initialize *args
    super
    self.fiber = Fiber.current
  end

  def wait
    Fiber.yield until status # it might be resumed by some other futures!
  end

  def resume
    return unless fiber.alive?
    EM.next_tick{
      begin
        fiber.resume
      rescue FiberError
        # whenever timeout, it would be already resumed,
        # and we have no way to tell if it's already resumed or not!
      end
    }
  end

  protected
  attr_accessor :fiber
end
