
require 'rest-core/test'

describe RC::QueryResponse do
  describe 'app' do
    app = RC::QueryResponse.new(RC::Dry.new, true)
    expected = {RC::RESPONSE_BODY => {},
                RC::REQUEST_HEADERS =>
                  {'Accept' => 'application/x-www-form-urlencoded'}}

    would 'give {} for nil' do
      app.call({}){ |response| response.should.eq(expected) }
    end

    would 'give {} for ""' do
      app.call(RC::RESPONSE_BODY => ''){ |r| r.should.eq(expected) }
    end

    would 'give {"a" => "b"} for "a=b"' do
      e = expected.merge(RC::RESPONSE_BODY => {'a' => 'b'})
      app.call(RC::RESPONSE_BODY => 'a=b'){ |r| r.should.eq(e) }
    end
  end

  describe 'client' do
    client = RC::Builder.client do
      use RC::QueryResponse, true
      run Class.new{
        def call env
          yield(env.merge(RC::RESPONSE_BODY => 'a=b&c=d'))
        end
      }
    end

    would 'do nothing' do
      expected = 'a=b&c=d'
      client.new(:query_response => false).get(''){ |response|
        response.should.eq(expected)
      }.get('').should.eq(expected)
    end

    would 'parse' do
      expected = {'a' => 'b', 'c' => 'd'}
      client.new.get(''){ |response|
        response.should.eq(expected)
      }.get('').should.eq(expected)
    end
  end
end
