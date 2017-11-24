
require 'rest-core/test'

describe RC::DefaultQuery do
  before do
    @app = RC::DefaultQuery.new(RC::Identity.new, {})
  end

  env = {RC::REQUEST_QUERY => {}}

  describe 'when given query' do
    would 'do nothing' do
      @app.call(env){ |r| r[RC::REQUEST_QUERY].should.eq({}) }
    end

    would 'merge query' do
      @app.instance_eval{@query = {'q' => 'uery'}}

      @app.call(env){ |r| r.should.eq({RC::REQUEST_QUERY => {'q' => 'uery'}}) }

      format = {'format' => 'json'}
      e      = {RC::REQUEST_QUERY => format}

      @app.call(e){ |r|
        r.should.eq({RC::REQUEST_QUERY => {'q' => 'uery'}.merge(format)}) }
    end

    would 'string_keys in query' do
      e = {'query' => {:symbol => 'value'}}
      @app.call(env.merge(e)){ |r|
        r.should.eq({RC::REQUEST_QUERY => {'symbol' => 'value'}}.merge(e))
      }
    end

    would 'also merge the very default query' do
      @app.query = {'a' => 'b'}
      @app.call('query' => {'b' => 'c'},
               RC::REQUEST_QUERY => {'c' => 'd'}) do |r|
        r[RC::REQUEST_QUERY].should.eq 'a' => 'b', 'b' => 'c', 'c' => 'd'
      end
    end
  end

  describe 'when not given query' do
    would 'merge query with {}' do
      @app.call(env){ |r| r.should.eq(RC::REQUEST_QUERY => {}) }
    end
  end
end
