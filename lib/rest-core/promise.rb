
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

  def self.create *args, &block
    if Fiber.respond_to?(:current) && RootFiber != Fiber.current &&
       # because under a thread, Fiber.current won't return the root fiber
       Thread.main == Thread.current
       FiberPromise.new(*args, &block)
    else
      ThreadPromise.new(*args, &block)
    end
  end

  def initialize env, k, immediate, &task
    self.env       = env
    self.k         = k
    self.immediate = immediate
    self.response, self.body, self.status, self.headers, self.error = nil
    gofor(&task) if task
  end

  def inspect
    "<#{self.class.name} for #{env[REQUEST_PATH]}>"
  end

  def future_body    ; Future.new(self, RESPONSE_BODY   ); end
  def future_status  ; Future.new(self, RESPONSE_STATUS ); end
  def future_headers ; Future.new(self, RESPONSE_HEADERS); end
  def future_failures; Future.new(self, FAIL)            ; end

  def wait  ; raise NotImplementedError; end
  def resume; raise NotImplementedError; end

  def gofor
    if pool_size < 0 # negative number for blocking call
      yield
    else
      defer{ yield }
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
                                      ["Future picked: #{self.class}"]))
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
    next_tick{ callback_in_async } if immediate
    resume # client or response might be waiting
  end

  def reject error
    self.error = if error.kind_of?(Exception)
                   error
                 else
                   Error.new(error || 'unknown')
                 end
    fulfill('', 0, {})
  end

  protected
  attr_accessor :env, :k, :immediate,
                :response, :body, :status, :headers, :error

  private
  def client_class; env[CLIENT].class; end
  def pool_size
    @pool_size ||= if client_class.respond_to?(:pool_size)
                     client_class.pool_size
                   else
                     0
                   end
  end

  # next_tick is used for telling the reactor that there's something else
  # should be done, don't sleep and don't stop at the moment
  def next_tick
    if Object.const_defined?(:EventMachine) && EventMachine.reactor_running?
      EventMachine.next_tick{ yield }
    else
      yield
    end
  end

  autoload :ThreadPromise, 'rest-core/promise/thread_promise'
  autoload :ThreadPool   , 'rest-core/promise/thread_pool'

  autoload :FiberPromise , 'rest-core/promise/fiber_promise'
end
