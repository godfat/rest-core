
require 'thread'

class RestCore::Promise::ThreadPool
  include RestCore

  class Task < Struct.new(:pool, :promise, :job)
    def call
      @thread = Thread.current
      promise.synchronize{ job.call } unless @cancelled
    rescue Exception => e
      warn "RestCore: ERROR: #{e}\n  from #{e.backtrace.inspect}"
    end
    # called from the other thread telling us it's timed out
    def kill
      @cancelled = true
      @thread.kill if @thread
      pool.refresh
    end
  end

  def self.[] client_class
    (@pools ||= {})[client_class] ||= new(client_class)
  end

  attr_reader :client_class, :tasks, :workers

  def initialize client_class
    @client_class  = client_class
    @tasks         = Queue.new
    @workers       = []
    @workers_mutex = Mutex.new
    refresh
  end

  def defer promise, &job
    refresh
    tasks << task = Task.new(self, promise, job)
    task
  end

  def refresh
    @workers_mutex.synchronize do
      (client_class.pool_size - workers.size).times do
        workers << Thread.new{
          Thread.current.abort_on_exception = true
          tasks.pop.call until @shutdown
        }
      end
    end
  end
end
