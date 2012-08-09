
class RestCore::Timeout::TimerThread
  attr_accessor :timeout, :error

  def initialize timeout, error, &block
    t = Thread.current
    self.timeout = timeout
    self.error   = error
    self.block   = block || lambda{ t.raise error }
    @canceled    = false
    start
  end

  def on_timeout &block
    self.block = block
  end

  def cancel
    @canceled = true
  end

  def canceled?
    @canceled
  end

  def start
    return if timeout.nil? || timeout.zero?
    self.thread = Thread.new{
      sleep(timeout)
      block.call unless canceled?
    }
  end

  protected
  attr_accessor :block, :thread
end
