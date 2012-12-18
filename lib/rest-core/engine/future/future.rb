
require 'rest-core'

class RestCore::Future
  include RestCore

  class Proxy < BasicObject
    def initialize future, target
      @future, @target = future, target
    end

    def method_missing msg, *args, &block
      @future.yield[@target].__send__(msg, *args, &block)
    end
  end

  def self.create *args, &block
    if Fiber.respond_to?(:current) && RootFiber != Fiber.current &&
       # because under a thread, Fiber.current won't return the root fiber
       Thread.main == Thread.current
      FutureFiber .new(*args, &block)
    else
      FutureThread.new(*args, &block)
    end
  end

  def initialize env, k, immediate
    self.env       = env
    self.k         = k
    self.immediate = immediate
    self.response, self.body, self.status, self.headers, self.error = nil
  end

  def proxy_body   ; Proxy.new(self, RESPONSE_BODY   ); end
  def proxy_status ; Proxy.new(self, RESPONSE_STATUS ); end
  def proxy_headers; Proxy.new(self, RESPONSE_HEADERS); end

  def wrap  ; raise NotImplementedError; end
  def wait  ; raise NotImplementedError; end
  def resume; raise NotImplementedError; end

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
    logger = method(:warn) # TODO: add error_log_method
    logger.call "RestCore: ERROR: #{e}\n  from #{e.backtrace.inspect}"
  end

  def on_load body, status, headers
    env[TIMER].cancel if env[TIMER]
    synchronize{
      self.body, self.status, self.headers = body, status, headers
    }
    # under ASYNC callback, should call immediately
    next_tick{ callback_in_async } if immediate
    resume # client or response might be waiting
  end

  def on_error error
    self.error = if error.kind_of?(Exception)
                   error
                 else
                   Error.new(error || 'unknown')
                 end
    on_load('', 0, {})
  end

  protected
  attr_accessor :env, :k, :immediate,
                :response, :body, :status, :headers, :error

  private
  def synchronize; yield; end
  # next_tick is used for telling the reactor that there's something else
  # should be done, don't sleep and don't stop at the moment
  def next_tick
    if Object.const_defined?(:EventMachine) && EventMachine.reactor_running?
      EventMachine.next_tick{ yield }
    else
      yield
    end
  end

  autoload :FutureFiber , 'rest-core/engine/future/future_fiber'
  autoload :FutureThread, 'rest-core/engine/future/future_thread'
end
