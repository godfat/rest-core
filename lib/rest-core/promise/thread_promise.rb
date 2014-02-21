
require 'thread'

class RestCore::Promise::ThreadPromise < RestCore::Promise
  def initialize *args
    super
    self.condv = ConditionVariable.new
    self.mutex = Mutex.new
  end

  def defer
    @thread = if pool_size > 0
                ThreadPool[client_class].defer(self){ yield }
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
    # If thread == Thread.current, it means we have errors from the task.
    # We shouldn't stop anything in this case.
    # If thread != Thread.current, it means we want to cancel the task,
    # maybe due to timing out or so, and we no longer care what's running
    # in the task, and we should be able to kill it safely.
    thread.kill if thread && thread != Thread.current
    super
  end

  def synchronize; mutex.synchronize{ yield }; end

  protected
  attr_accessor :condv, :mutex, :thread
end
