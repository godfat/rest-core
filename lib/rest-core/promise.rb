
require 'thread'
require 'rest-core'

class RestCore::Promise
  include RestCore

  class Future < BasicObject
    def initialize promise, target
      @promise, @target = promise, target
    end

    def method_missing msg, *args, &block
      @promise.yield[@target].__send__(msg, *args, &block)
    end
  end

  def initialize env, k=RC.id, immediate=false, &task
    self.env       = env
    self.k         = k
    self.immediate = immediate
    self.response, self.body, self.status, self.headers, self.error = nil
    self.condv     = ConditionVariable.new
    self.mutex     = Mutex.new
    defer(&task) if task
  end

  def inspect
    "<#{self.class.name} for #{env[REQUEST_PATH]}>"
  end

  def future_body    ; Future.new(self, RESPONSE_BODY   ); end
  def future_status  ; Future.new(self, RESPONSE_STATUS ); end
  def future_headers ; Future.new(self, RESPONSE_HEADERS); end
  def future_failures; Future.new(self, FAIL)            ; end

  def wait
    # it might be awaken by some other futures!
    mutex.synchronize{ condv.wait(mutex) until loaded? } unless loaded?
  end

  def resume
    condv.broadcast
  end

  def defer
    if pool_size < 0 # negative number for blocking call
      yield
    elsif pool_size > 0
      self.task = ThreadPool[client_class].defer(self){ yield }
    else
      Thread.new{ mutex.synchronize{yield} }
    end
  end

  def loaded?
    !!status
  end

  def yield
    wait
    callback
  end

  def callback
    self.response ||= k.call(
      env.merge(RESPONSE_BODY    => body  ,
                RESPONSE_STATUS  => status,
                RESPONSE_HEADERS => headers,
                FAIL             => ((env[FAIL]||[]) + [error]).compact,
                LOG              =>  (env[LOG] ||[]) +
                                      ["Promise picked: #{self.class}"]))
  end

  def callback_in_async
    callback
  rescue Exception => e
    # nothing we can do here for an asynchronous exception,
    # so we just log the error
    # TODO: add error_log_method
    warn "RestCore: ERROR: #{e}\n  from #{e.backtrace.inspect}"
  end

  def fulfill body, status, headers
    env[TIMER].cancel if env[TIMER]
    self.body, self.status, self.headers = body, status, headers
    # under ASYNC callback, should call immediately
    callback_in_async if immediate
    resume # client or response might be waiting
  end

  def reject error
    task.cancel if task

    self.error = if error.kind_of?(Exception)
                   error
                 else
                   Error.new(error || 'unknown')
                 end
    fulfill('', 0, {})
  end

  protected
  attr_accessor :env, :k, :immediate,
                :response, :body, :status, :headers, :error,
                :condv, :mutex, :task

  private
  def client_class; env[CLIENT].class; end
  def pool_size
    @pool_size ||= if client_class.respond_to?(:pool_size)
                     client_class.pool_size
                   else
                     0
                   end
  end
end
