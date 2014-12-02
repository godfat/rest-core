
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
      end
    end.new
    @app = RC::Retry.new(engine, 5)
  end

  would 'retry max_retries times' do
    @errors.replace([RuntimeError.new] * @app.max_retries({}))
    @app.call({RC::FAIL => [true]}){}
    @called.size.should.eq @app.max_retries({}) + 1
    @errors.size.should.eq 0
  end

  would 'retry several times' do
    @errors.replace([RuntimeError.new] * 2)
    @app.call({RC::FAIL => [true]}){}
    @called.size.should.eq 3
    @errors.size.should.eq 0
  end
end
