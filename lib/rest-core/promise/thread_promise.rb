
require 'thread'

class RestCore::Promise::ThreadPromise < RestCore::Promise
  def initialize *args
    super
    self.condv = ConditionVariable.new
    self.mutex = Mutex.new
  end

  def defer
    if pool_size > 0
      self.task = ThreadPool[client_class].defer(self){ yield }
    else
      Thread.new{ synchronize{yield} }
    end
  end

  def wait
    # it might be awaken by some other futures!
    synchronize{ condv.wait(mutex) until loaded? } unless loaded?
  end

  def resume
    condv.broadcast
  end

  def reject error
    task.cancel if task
    super
  end

  def synchronize; mutex.synchronize{ yield }; end

  protected
  attr_accessor :condv, :mutex, :task
end
