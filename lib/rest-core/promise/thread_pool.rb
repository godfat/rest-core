
# reference implementation: puma
# https://github.com/puma/puma/blob/v2.7.1/lib/puma/thread_pool.rb

require 'thread'

class RestCore::Promise::ThreadPool
  include RestCore

  class Task < Struct.new(:pool, :promise, :job)
    def inspect
      "#<struct promise=#{promise.inspect}>"
    end
    alias_method :to_s, :inspect

    def call
      @thread = Thread.current
      promise.synchronize{ job.call } unless cancelled
      @thread = nil # should only kill the thread for user tasks
      true
    rescue Exception => e # should never happen, but just in case
      warn "RestCore: ERROR: #{e}\n  from #{e.backtrace.inspect}"
      promise.reject(e)   # should never deadlock someone
      true
    end
    # called from the other thread telling us it's timed out
    def kill
      @cancelled = true
      # we don't need to do anything if thread == Thread.current,
      # because this thread would need to handle user callback,
      # and the original request should already be cancelled and
      # we're already sending back the exception
      if thread && thread != Thread.current
        # # don't kill for now, we're not yet properly handling this
        # thread.kill
      end
    end
    protected
    attr_reader :thread, :mutex, :cancelled
  end

  def self.[] client_class
    (@pools ||= {})[client_class] ||= new(client_class)
  end

  attr_reader :client_class

  def initialize client_class
    @client_class = client_class
    @queue        = Queue.new
    @mutex        = Mutex.new
    @workers      = []
    @waiting      = 0
  end

  def inspect
    "#<#{self.class.name} client_class=#{client_class}>"
  end

  def max_size
    client_class.pool_size
  end

  def defer promise, &job
    mutex.synchronize do
      task = Task.new(self, promise, job)
      queue << task
      spawn_worker if waiting == 0 && workers.size < max_size
      task
    end
  end

  def trim force=false
    queue << lambda{ false } if force || waiting > 0
  end

  # Block on shutting down, and should not add more jobs while shutting down
  def shutdown
    workers.size.times{ trim(true) }
    workers.first.join && trim(true) until workers.empty?
    queue.clear
  end

  protected
  attr_reader :queue, :mutex, :condv, :workers, :waiting

  private
  def spawn_worker
    workers << Thread.new{
      Thread.current.abort_on_exception = !!$DEBUG

      task = nil
      begin
        mutex.synchronize{ @waiting += 1 }
        task = queue.pop
        mutex.synchronize{ @waiting -= 1 }
      end while task.call

      mutex.synchronize{ workers.delete(Thread.current) }
    }
  end
end
