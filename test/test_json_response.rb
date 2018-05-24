
require 'rest-core/test'

describe RC::JsonResponse do
  describe 'app' do
    app = RC::JsonResponse.new(RC::Identity.new, true)
    bad = 'bad json'

    would 'do nothing' do
      expected = {RC::RESPONSE_BODY => nil,
                  RC::REQUEST_HEADERS => {'Accept' => 'application/json'}}
      app.call(RC::RESPONSE_BODY => '') do |response|
        response.should.eq(expected)
      end
    end

    would 'decode' do
      expected = {RC::RESPONSE_BODY => {},
                  RC::REQUEST_HEADERS => {'Accept' => 'application/json'}}
      app.call(RC::RESPONSE_BODY => '{}') do |response|
        response.should.eq(expected)
      end

      expected = {RC::RESPONSE_BODY => nil,
                  RC::REQUEST_HEADERS => {'Accept' => 'application/json'}}
      app.call({}) do |response|
        response.should.eq(expected)
      end
    end

    would 'give proper parse error' do
      app.call(RC::RESPONSE_BODY => bad) do |response|
        err = response[RC::FAIL].first
        err.should.kind_of?(RC::Json.const_get(:ParseError))
        err.should.kind_of?(RC::JsonResponse::ParseError)
      end
    end

    would 'give me original text' do
      app.call(RC::RESPONSE_BODY => bad) do |response|
        err = response[RC::FAIL].first
        err.message    .should.include?(bad)
        err.body       .should.eq(bad)
        err.cause.class.should.eq(RC::Json.const_get(:ParseError))
      end
    end

    would 'remove UTF-8 BOM' do
      body = %Q{\xEF\xBB\xBF"UTF-8"}

      app.call(RC::RESPONSE_BODY => body) do |response|
        expect(response[RC::RESPONSE_BODY]).eq 'UTF-8'
      end
    end

    would 'remove UTF-8 BOM for ASCII-8BIT' do
      body = %Q{\xEF\xBB\xBF"UTF-8"}.force_encoding('ASCII-8BIT')

      app.call(RC::RESPONSE_BODY => body) do |response|
        expect(response[RC::RESPONSE_BODY]).eq 'UTF-8'
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

    would 'do nothing' do
      expected = '{}'
      client.new(:json_response => false).get(''){ |response|
        response.should.eq(expected)
      }.get('').should.eq(expected)
    end

    would 'decode' do
      expected = {}
      client.new.get(''){ |response|
        response.should.eq(expected)
      }.get('').should.eq(expected)
    end
  end
end
