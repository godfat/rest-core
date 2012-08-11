
require 'fiber'

class RestCore::Future::FutureFiber < RestCore::Future
  def initialize *args
    super
    self.fibers = []
  end

  def wait
    fibers << Fiber.current
    Fiber.yield until loaded? # it might be resumed by some other futures!
  end

  def resume
    return if fibers.empty?
    current_fibers = fibers.dup
    fibers.clear
    current_fibers.each{ |f|
      next unless f.alive?
      EM.next_tick{
        begin
          f.resume
        rescue FiberError
          # whenever timeout, it would be already resumed,
          # and we have no way to tell if it's already resumed or not!
        end
      }
    }
    resume
  end

  protected
  attr_accessor :fibers
end
