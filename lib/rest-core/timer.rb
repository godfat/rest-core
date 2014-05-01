
require 'timers'

class RestCore::Timer
  TimerGen = Timers.new

  attr_accessor :timeout, :error
  def initialize timeout, error, &block
    self.timeout = timeout
    self.error   = error
    self.block   = block
    start
  end

  def on_timeout &block
    self.block = block
  end

  def cancel
    timer.cancel
  end

  def start
    return if timeout.nil? || timeout.zero?
    self.timer = TimerGen.after(timeout){ block.call }
  end

  protected
  attr_accessor :block, :timer
end
