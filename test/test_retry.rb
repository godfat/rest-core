
require 'rest-core/test'

describe RC::Retry do
  before do
    @called = called = []
    @errors = errors = []
    engine = Class.new do
      define_method :call do |env, &block|
        called << true
        env[RC::FAIL].should.eq [true]
        block.call(env.merge(RC::FAIL => [true, errors.shift]))
        {}
      end
    end.new
    @app = RC::Retry.new(engine, 5)
  end

  after do
    @errors.size.should.eq 0
  end

  def call env={}
    @app.call({RC::FAIL => [true]}.merge(env)){}
  end

  def max_retries
    @app.max_retries({})
  end

  would 'retry max_retries times' do
    @errors.replace([IOError.new] * max_retries)
    call
    @called.size.should.eq max_retries + 1
  end

  would 'retry several times' do
    @errors.replace([IOError.new] * 2)
    call
    @called.size.should.eq 3
  end

  would 'not retry RuntimeError by default' do
    @errors.replace([RuntimeError.new])
    call
    @called.size.should.eq 1
  end

  would 'retry RuntimeError when setup' do
    @errors.replace([RuntimeError.new] * max_retries)
    @app.retry_exceptions = [RuntimeError]
    call
    @called.size.should.eq max_retries + 1
  end

  would 'call error_callback upon retrying' do
    @errors.replace([IOError.new] * 2)
    errors = []
    call(RC::CLIENT => stub.error_callback{errors.method(:<<)}.object)
    @called.size.should.eq 3
    errors.size.should.eq 2
  end
end
