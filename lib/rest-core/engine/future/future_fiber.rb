
require 'fiber'

class RestCore::Future::FutureFiber < RestCore::Future
  def initialize *args
    super
    self.fibers = []
  end

  def wrap
    Fiber.new{ yield }.resume
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
      next_tick{ f.resume }
    }
    resume
  end

  protected
  attr_accessor :fibers
end
