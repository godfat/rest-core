
require 'rest-core/test'

describe RC::Promise do
  should 'work, reject, yield' do
    client           = RC::Builder.client
    client.pool_size = 1
    flag             = 0
    promise          = RC::Promise.new(RC::CLIENT => client.new) do
      flag.should.eq 0
      flag += 1
      promise.reject(nil)
    end
    promise.yield
    flag.should.eq 1
  end
end
