
require 'rest-core/test'

describe RC::DefaultQuery do
  before do
    @app = RC::DefaultQuery.new(RC::Dry.new, {})
  end

  describe 'when given query' do
    should 'do nothing' do
      @app.call({}){ |r| r[RC::REQUEST_QUERY].should.eq({}) }
    end

    should 'merge query' do
      @app.instance_eval{@query = {'q' => 'uery'}}

      @app.call({}){ |r| r.should.eq({RC::REQUEST_QUERY => {'q' => 'uery'}}) }

      format = {'format' => 'json'}
      env    = {RC::REQUEST_QUERY => format}

      @app.call(env){ |r|
        r.should.eq({RC::REQUEST_QUERY => {'q' => 'uery'}.merge(format)}) }
    end
  end

  describe 'when not given query' do
    should 'merge query with {}' do
      @app.call({}){ |r| r.should.eq({RC::REQUEST_QUERY => {}}) }
    end
  end
end
