
require 'rest-core/test'

describe RC::ThreadPool do
  should 'have the same pool for the same client' do
    client = RC::Builder.client
    pool   = RC::ThreadPool[client]
    RC::ThreadPool[client].object_id.should.eq pool.object_id
  end
end
