
# reference implementation: puma
# https://github.com/puma/puma/blob/v2.7.1/lib/puma/thread_pool.rb

require 'thread'
require 'rest-core'

class RestCore::ThreadPool
  include RestCore

  class Queue
    def initialize
      @queue = []
      @condv = ConditionVariable.new
    end

    def size
      @queue.size
    end

    def << task
      queue << task
      condv.signal
    end

    def pop mutex, timeout=60
      if queue.empty?
        condv.wait(mutex, timeout)
        queue.shift || lambda{ |_| false } # shutdown idle workers
      else
        queue.shift
      end
    end

    def clear
      queue.clear
    end

    protected
    attr_reader :queue, :condv
  end

  class Task < Struct.new(:job, :mutex, :thread, :cancelled)
    # this should never fail
    def call working_thread
      mutex.synchronize do
        return if cancelled
        self.thread = working_thread
      end
      job.call
      true
    end

    def cancel
      self.cancelled = true
    end
  end

  def self.[] client_class
    (@pools ||= {})[client_class] ||= new(client_class)
  end

  attr_reader :client_class, :queue, :workers, :waiting

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

  def size
    workers.size
  end

  def max_size
    client_class.pool_size
  end

  def idle_time
    client_class.pool_idle_time
  end

  def defer promise_mutex, &job
    mutex.synchronize do
      task = Task.new(job, promise_mutex)
      queue << task
      spawn_worker if waiting < queue.size && workers.size < max_size
      task
    end
  end

  def trim force=false
    mutex.synchronize do
      queue << lambda{ |_| false } if force || waiting > 0
    end
  end

  # Block on shutting down, and should not add more jobs while shutting down
  def shutdown
    workers.size.times{ trim(true) }
    workers.first.join && trim(true) until workers.empty?
    mutex.synchronize{ queue.clear }
  end

  protected
  attr_reader :mutex, :condv

  private
  def spawn_worker
    workers << Thread.new{
      Thread.current.abort_on_exception = true

      task = nil
      begin
        mutex.synchronize do
          @waiting += 1
          task = queue.pop(mutex, idle_time)
          @waiting -= 1
        end
      end while task.call(Thread.current)

      mutex.synchronize{ workers.delete(Thread.current) }
    }
  end
end
