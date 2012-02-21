
class RestCore::Timeout::EventMachineTimer < ::EventMachine::Timer
  attr_accessor :timeout, :error

  def initialize timeout, error, &block
    super(timeout, &block) if block_given?
    self.timeout = timeout
    self.error   = error
  end

  def on_timeout &block
    send(:initialize, timeout, error, &block)
  end
end
