
require 'rest-core/test'

describe RC::JsonResponse do
  describe 'app' do
    app = RC::JsonResponse.new(RC::Dry.new, true)
    bad = 'bad json'

    should 'do nothing' do
      expected = {RC::RESPONSE_BODY => nil,
                  RC::REQUEST_HEADERS => {'Accept' => 'application/json'}}
      app.call({}){ |response| response.should.eq(expected) }
    end

    should 'decode' do
      expected = {RC::RESPONSE_BODY => {},
                  RC::REQUEST_HEADERS => {'Accept' => 'application/json'}}
      app.call(RC::RESPONSE_BODY => '{}') do |response|
        response.should.eq(expected)
      end
    end

    should 'give proper parse error' do
      app.call(RC::RESPONSE_BODY => bad) do |response|
        err = response[RC::FAIL].first
        err.should.kind_of(RC::Json.const_get(:ParseError))
        err.should.kind_of(RC::JsonResponse::ParseError)
      end
    end

    should 'give me original text' do
      app.call(RC::RESPONSE_BODY => bad) do |response|
        err = response[RC::FAIL].first
        err.message    .should.include(bad)
        err.body       .should.eq(bad)
        err.cause.class.should.eq(RC::Json.const_get(:ParseError))
      end
    end
  end

  describe 'client' do
    client = RC::Builder.client do
      use RC::JsonResponse, true
      run Class.new{
        def call env
          yield(env.merge(RC::RESPONSE_BODY => '{}'))
        end
      }
    end

    should 'do nothing' do
      expected = '{}'
      client.new(:json_response => false).get(''){ |response|
        response.should.eq(expected)
      }.get('').should.eq(expected)
    end

    should 'decode' do
      expected = {}
      client.new.get(''){ |response|
        response.should.eq(expected)
      }.get('').should.eq(expected)
    end
  end
end
