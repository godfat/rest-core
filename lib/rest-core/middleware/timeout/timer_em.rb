
require 'eventmachine'

class RestCore::Timeout::TimerEm < ::EventMachine::Timer
  attr_accessor :timeout, :error

  def initialize timeout, error, &block
    super(timeout, &block) if block_given?
    self.timeout = timeout
    self.error   = error
    @canceled    = false
  end

  def on_timeout &block
    send(:initialize, timeout, error, &block)
  end

  def cancel
    super
    @canceled = true
  end

  def canceled?
    @canceled
  end
end
