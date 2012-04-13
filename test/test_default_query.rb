
require 'rest-core/test'

describe RC::DefaultQuery do
  describe 'when given query' do
    before do
      @app = RC::DefaultQuery.new(RC::Dry.new, {})
    end

    def app
      @app
    end

    should 'do nothing' do
      app.call({})[RC::REQUEST_QUERY].should.eq({})
    end

    should 'merge query' do
      app.instance_eval{@query = {'q' => 'uery'}}

      app.call({}).should.eq({RC::REQUEST_QUERY =>
        {'q' => 'uery'}})

      format = {'format' => 'json'}
      env    = {RC::REQUEST_QUERY => format}

      app.call(env).should.eq({RC::REQUEST_QUERY =>
        {'q' => 'uery'}.merge(format)})
    end
  end

  describe 'when not given query' do
    before do
      @app = RC::DefaultQuery.new(RC::Dry.new)
    end

    def app
      @app
    end

    should 'merge query with {}' do
      app.call({}).should.eq({RC::REQUEST_QUERY => {}})
    end
  end
end
