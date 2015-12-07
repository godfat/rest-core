
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

  def self.claim env, k=RC.id, body, status, headers
    promise = new(env, k, env[ASYNC])
    promise.fulfill(body, status, headers)
    promise
  end

  def self.backtrace
    Thread.current[:backtrace] || []
  end

  # should never raise!
  def self.set_backtrace e
    e.set_backtrace((e.backtrace || caller) + backtrace)
  end

  def initialize env, k=RC.id, immediate=false, &job
    self.env       = env
    self.k         = [k]
    self.immediate = immediate

    self.body, self.status, self.headers, self.socket,
      self.response, self.error, self.called = nil

    self.condv     = ConditionVariable.new
    self.mutex     = Mutex.new

    defer(&job) if job
  end

  def inspect
    "<#{self.class.name} for #{env[REQUEST_URI]}>"
  end

  def future_body    ; Future.new(self, RESPONSE_BODY   ); end
  def future_status  ; Future.new(self, RESPONSE_STATUS ); end
  def future_headers ; Future.new(self, RESPONSE_HEADERS); end
  def future_socket  ; Future.new(self, RESPONSE_SOCKET ); end
  def future_failures; Future.new(self, FAIL)            ; end
  def future_response
    env.merge(RESPONSE_BODY    => future_body,
              RESPONSE_STATUS  => future_status,
              RESPONSE_HEADERS => future_headers,
              RESPONSE_SOCKET  => future_socket,
              FAIL             => future_failures,
              PROMISE          => self)
  end

  # called in client thread
  def defer
    if pool_size < 0 # negative number for blocking call
      self.thread = Thread.current # set working thread
      protected_yield{ yield } # avoid any exception and do the job
    else
      backtrace = caller + self.class.backtrace # retain the backtrace so far
      if pool_size > 0
        mutex.synchronize do
          # still timing it out if the task never processed
          env[TIMER].on_timeout{ cancel_task } if env[TIMER]
          self.task = client_class.thread_pool.defer(mutex) do
            Thread.current[:backtrace] = backtrace
            protected_yield{ yield }
            Thread.current[:backtrace] = nil
          end
        end
      else
        self.thread = Thread.new do
          Thread.current[:backtrace] = backtrace
          protected_yield{ yield }
        end
      end
    end
  end

  # called in client thread (client.wait)
  def wait
    # it might be awaken by some other futures!
    mutex.synchronize{ condv.wait(mutex) until done? } unless done?
  end

  # called in client thread (from the future (e.g. body))
  def yield
    wait
    callback
  end

  # called in requesting thread after the request is done
  def fulfill body, status, headers, socket=nil
    env[TIMER].cancel if env[TIMER]
    mutex.synchronize{ fulfilling(body, status, headers, socket) }
  end

  # called in requesting thread if something goes wrong or timed out
  def reject error
    env[TIMER].cancel if env[TIMER]
    mutex.synchronize{ rejecting(error) }
  end

  # append your actions, which would be called when we're calling back
  def then &action
    k << action
    self
  end

  # called in Client.defer to mark this promise as done
  def done
    fulfill('', 0, {})
  end

  # It's considered done only if the HTTP request is done, and we're not
  # in asynchronous mode otherwise the callback should be called first.
  # For synchronous mode, since we're waiting for the callback anyway,
  # we don't really have to check if it's called.
  def done?
    !!status && (!immediate || called)
  end

  protected
  attr_accessor :env, :k, :immediate,
                :body, :status, :headers, :socket,
                :response, :error, :called,
                :condv, :mutex, :task, :thread

  private
  def fulfilling body, status, headers, socket=nil
    self.body, self.status, self.headers, self.socket =
      body, status, headers, socket
    # under ASYNC callback, should call immediately
    callback if immediate
  ensure
    condv.broadcast # client or response might be waiting
  end

  def rejecting error
    self.error = if error.kind_of?(Exception)
                   error
                 else
                   Error.new(error || 'unknown')
                 end
    fulfilling('', 0, {})
  end

  # called in a new thread if pool_size == 0, otherwise from the pool
  # i.e. requesting thread
  def protected_yield
    if env[TIMER]
      timeout_protected_yield{ yield }
    else
      yield
    end
  rescue Exception => e
    mutex.synchronize do
      self.class.set_backtrace(e)
      if done? # log user callback error
        callback_error(e)
      else # IOError, SystemCallError, etc
        begin
          rejecting(e) # would call user callback
        rescue Exception => f # log user callback error
          callback_error(f){ self.class.set_backtrace(f) }
        end
      end
    end
  end

  def timeout_protected_yield
    # timeout might already be set for thread_pool (pool_size > 0)
    env[TIMER].on_timeout{ cancel_task } unless env[TIMER].timer
    yield
  ensure
    env[TIMER].cancel
  end

  # called in client thread, when yield is called
  def callback
    return response if called
    self.response = k.inject(
      env.merge(RESPONSE_BODY    => body  ,
                RESPONSE_STATUS  => status,
                RESPONSE_HEADERS => headers,
                RESPONSE_SOCKET  => socket,
                FAIL             => ((env[FAIL]||[]) + [error]).compact,
                LOG              =>   env[LOG] ||[])){ |r, i| i.call(r) }
  ensure
    self.called = true
  end

  # log user callback error
  def callback_error e
    never_raise_yield do
      yield if block_given?
      if env[CLIENT].error_callback
        env[CLIENT].error_callback.call(e)
      else
        warn "RestCore: ERROR: #{e}\n  from #{e.backtrace.inspect}"
      end
    end
  end

  # timeout!
  def cancel_task backtrace=nil
    mutex.synchronize do
      next if done? # don't cancel if it's done
      if t = thread || task.thread
        t.raise(env[TIMER].error) # raise Timeout::Error to working thread
      else    # task was queued and never started, just cancel it and
        begin # fulfill the promise with Timeout::Error
          task.cancel
          rejecting(env[TIMER].error)
        rescue Exception => e # log user callback error
          callback_error(e){e.set_backtrace(e.backtrace + (backtrace || []))}
        end
      end
    end
  end

  # only use this for unimportant stuffs and in most critical section
  # e.g. error logging in critical section
  def never_raise_yield
    yield
  rescue Exception => e
    Thread.main.raise(e) if !!$DEBUG
  end

  def client_class; env[CLIENT].class; end
  def pool_size
    @pool_size ||= if client_class.respond_to?(:pool_size)
                     client_class.pool_size
                   else
                     0
                   end
  end
end
