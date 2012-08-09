
require 'thread'

class RestCore::Future::FutureThread < RestCore::Future
  def initialize *args
    super
    self.thread = Thread.current
    self.mutex  = Mutex.new
  end

  def wait
    # it might be awaken by some other futures!
    synchronize{ mutex.sleep until status }
  end

  def resume
    return unless thread.alive? && thread.stop?
    thread.wakeup
  rescue ThreadError
  end

  protected
  attr_accessor :thread, :mutex

  private
  def synchronize; mutex.synchronize{ yield }; end
end
