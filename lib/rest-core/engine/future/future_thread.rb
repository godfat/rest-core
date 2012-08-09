
require 'thread'

class RestCore::Future::FutureThread < RestCore::Future
  def initialize *args
    super
    self.condv = ConditionVariable.new
    self.mutex = Mutex.new
  end

  def wait
    # it might be awaken by some other futures!
    synchronize{ condv.wait(mutex) until status }
  end

  def resume
    condv.broadcast
  end

  protected
  attr_accessor :condv, :mutex

  private
  def synchronize; mutex.synchronize{ yield }; end
end
