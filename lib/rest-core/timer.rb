
require 'timers'

class RestCore::Timer
  TimerGen = Timers::Group.new
  TimerGen.every(1){}
  Thread = ::Thread.new do
    begin
      TimerGen.wait
    rescue => e
      warn "timeout exception: #{e}"
    end while 'not exiting'
  end

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
    self.block = nil
  end

  def start
    return if timeout.nil? || timeout.zero?
    self.timer = TimerGen.after(timeout){ block.call if block }
  end

  protected
  attr_accessor :block, :timer
end
