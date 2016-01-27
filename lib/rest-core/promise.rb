
require 'promise_pool/promise'

module RestCore
  class Promise < PromisePool::Promise
    class Future < PromisePool::Future
      def initialize promise, key
        super(promise)
        @key = key
      end

      def method_missing msg, *args, &block
        @promise.yield[@key].__send__(msg, *args, &block)
      end
    end

    def future_status  ; Future.new(self, RESPONSE_STATUS ); end
    def future_headers ; Future.new(self, RESPONSE_HEADERS); end
    def future_body    ; Future.new(self, RESPONSE_BODY   ); end
    def future_socket  ; Future.new(self, RESPONSE_SOCKET ); end
    def future_failures; Future.new(self, FAIL            ); end
    def future_response
      {RESPONSE_STATUS  => future_status  ,
       RESPONSE_HEADERS => future_headers ,
       RESPONSE_BODY    => future_body    ,
       RESPONSE_SOCKET  => future_socket  ,
       FAIL             => future_failures,
       PROMISE          => self}
    end
  end
end
