
require 'rest-core/test'

describe RC::JsonDecode do
  describe 'app' do
    def app
      @app ||= RC::JsonDecode.new(RC::Dry.new, true)
    end

    should 'do nothing' do
      expected = {RC::RESPONSE_BODY => nil}
      app.call({}){ |response| response.should.eq(expected) }
    end

    should 'decode' do
      expected = {RC::RESPONSE_BODY => {}}
      app.call(RC::RESPONSE_BODY => '{}'){ |response|
        response.should.eq(expected)
      }
    end
  end

  describe 'client' do
    def client
      @client ||= RC::Builder.client do
        use RC::JsonDecode, true
        run Class.new{
          def call env
            yield(env.merge(RC::RESPONSE_BODY => '{}'))
          end
        }
      end
    end

    should 'do nothing' do
      expected = '{}'
      client.new(:json_decode => false).get(''){ |response|
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
