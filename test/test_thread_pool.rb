
require 'rest-core/test'

describe RC::ThreadPool do
  # would 'have the same pool for the same client' do
  #   client = RC::Builder.client
  #   pool   = RC::ThreadPool[client]
  #   RC::ThreadPool[client].object_id.should.eq pool.object_id
  # end

  would 'not waiting forever' do
    skip
    mutex = Mutex.new
    condv = ConditionVariable.new
    klass = Struct.new(:pool_size, :pool_idle_time).new(2, 10)
    pool = RC::ThreadPool[klass]
    pool.defer(mutex){mutex.synchronize{ condv.signal }} # populate one worker
    mutex.synchronize{ condv.wait(mutex) }
    called = []
    pool.defer(mutex) do
      sleep 1
      called << 0
    end
    pool.defer(mutex) do
      sleep 1
      called << 0
      pool.defer(mutex) do
        called << 1
      end
    end
    sleep 5
    p called
    ok
  end
end
