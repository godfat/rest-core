
require 'rest-core'

class RestCore::ResponseThunk
  include RestCore

  class Proxy < BasicObject
    def initialize thunk, target
      @thunk, @target = thunk, target
    end

    def method_missing msg, *args, &block
      load.__send__(msg, *args, &block)
    end

    def load
      @thunk.yield[@target]
    end

    def loaded?
      !!@thunk.status
    end
  end

  def initialize env, k
    self.env      = env
    self.k        = k
    self.fiber    = Fiber.current
    self.response = nil
    self.body, self.status, self.headers = nil, nil, nil
  end

  def proxy_body   ; Proxy.new(self, RESPONSE_BODY   ); end
  def proxy_status ; Proxy.new(self, RESPONSE_STATUS ); end
  def proxy_headers; Proxy.new(self, RESPONSE_HEADERS); end

  def yield
    Fiber.yield until status # it might be resumed by some other thunks!
    self.response ||= k.call(
      env.merge(RESPONSE_BODY    => body  ,
                RESPONSE_STATUS  => status,
                RESPONSE_HEADERS => headers))
  end

  def on_load body, status, headers
    env[TIMER].cancel if env[TIMER]
    self.body, self.status, self.headers = body, status, headers
    fiber.resume if fiber.alive?
  rescue FiberError
    # whenever timeout, it would be already resumed,
    # and we have no way to tell if it's already resumed or not!
  end

  protected
  attr_accessor :env, :k, :fiber, :response, :body, :status, :headers
end
