
require 'thread'

class RestCore::Promise::PromiseThread < RestCore::Promise
  def initialize *args
    super
    self.condv = ConditionVariable.new
    self.mutex = Mutex.new
  end

  def gofor
    Thread.new{ yield }
  end

  def wait
    # it might be awaken by some other futures!
    synchronize{ condv.wait(mutex) until loaded? } unless loaded?
  end

  def resume
    condv.broadcast
  end

  protected
  attr_accessor :condv, :mutex

  private
  def synchronize; mutex.synchronize{ yield }; end
end
