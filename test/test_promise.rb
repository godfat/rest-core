
require 'rest-core/test'

describe RC::Promise do
  should 'work, reject, yield' do
    client           = RC::Builder.client
    client.pool_size = 1
    flag             = 0
    promise          = RC::Promise.new(RC::CLIENT => client.new)
    promise.defer do
      flag.should.eq 0
      flag += 1
      promise.reject(nil)
    end
    promise.yield
    flag.should.eq 1
    promise.send(:error).should.kind_of RC::Error
    client.thread_pool.shutdown
  end

  should 'work, fulfill, yield' do
    client           = RC::Builder.client
    client.pool_size = 2
    flag             = 0
    promise          = RC::Promise.new(RC::CLIENT => client.new)
    promise.defer do
      flag.should.eq 0
      flag += 1
      promise.fulfill('body', 1, {'K' => 'V'})
    end
    promise.yield
    flag.should.eq 1
    promise.send(:body)   .should.eq 'body'
    promise.send(:status) .should.eq 1
    promise.send(:headers).should.eq('K' => 'V')
    client.thread_pool.shutdown
  end
end
