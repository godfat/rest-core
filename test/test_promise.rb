
require 'rest-core/test'

describe RC::Promise do
  def new_promise
    RC::Promise.new(RC::CLIENT => @client.new)
  end

  before do
    @client  = RC::Builder.client
    @promise = new_promise
  end

  after do
    @client.shutdown
    @client.thread_pool.size.should.eq 0
    Muack.verify
  end

  would 'work, reject, yield' do
    @client.pool_size = 1
    flag = 0
    @promise.defer do
      flag.should.eq 0
      flag += 1
      @promise.reject(nil)
    end
    @promise.yield
    flag.should.eq 1
    @promise.send(:error).should.kind_of? RC::Error
  end

  would 'work, fulfill, yield' do
    @client.pool_size = 2
    flag = 0
    @promise.defer do
      flag.should.eq 0
      flag += 1
      @promise.fulfill('body', 1, {'K' => 'V'})
    end
    @promise.yield
    flag.should.eq 1
    @promise.send(:body)   .should.eq 'body'
    @promise.send(:status) .should.eq 1
    @promise.send(:headers).should.eq('K' => 'V')
  end

  would 'warn on callback error' do
    mock(any_instance_of(RC::Promise)).warn(is_a(String)) do |msg|
      msg.should.eq 'boom'
    end

    @client.new.get('http://localhost/') do |err|
      err.should.kind_of?(Errno::ECONNREFUSED)
      raise 'boom'
    end.wait
  end

  would 'call error_callback on errors' do
    errors = []
    @client.new(:error_callback => lambda{ |e| errors << e }).
      get('http://localhost/') do |err|
        err.should.kind_of?(Errno::ECONNREFUSED)
        raise 'boom'
      end.wait
    errors.map(&:class).should.eq [Errno::ECONNREFUSED, RuntimeError]
  end

  would 'then then then' do
    plusone = lambda do |r|
      r.merge(RC::RESPONSE_BODY => r[RC::RESPONSE_BODY] + 1)
    end
    2.times{ @promise.then(&plusone).then(&plusone).then(&plusone) }
    @promise.fulfill(0, 200, {})
    @promise.future_body.should.eq 6
  end

  would 'call inline if pool_size < 0' do
    @client.pool_size = -1
    current_thread = Thread.current
    @promise.defer do
      Thread.current.should.eq current_thread
    end
  end

  would 'call in a new thread if pool_size == 0' do
    @client.pool_size = 0
    thread = nil
    rd, wr = IO.pipe
    mock(Thread).new.with_any_args.peek_return do |t|
      thread = t
      wr.puts
    end
    @promise.defer do
      rd.gets
      Thread.current.should.eq thread
      @promise.reject(nil)
    end
    @promise.yield
  end

  would 'call in thread pool if pool_size > 0' do
    @client.pool_size = 1
    flag = 0
    rd, wr = IO.pipe
    @promise.defer do
      rd.gets
      flag.should.eq 0
      flag += 1
      @promise.reject(nil)
    end
    p1 = new_promise
    p1.defer do # block until promise #0 is done because pool_size == 1
      flag.should.eq 1
      flag += 1
      p1.reject(nil)
    end
    wr.puts  # start promise #0
    @promise.yield
    p1.yield # block until promise #1 is done
    flag.should.eq 2
  end
end
