
require 'rest-core/test'

describe RC::ClashResponse do
  describe 'app' do
    app = RC::ClashResponse.new(RC::Dry.new, true)

    should 'do nothing' do
      env = {RC::RESPONSE_BODY => []}
      app.call(env) do |res|
        res.should.eq(env)
        res[RC::RESPONSE_BODY].should.kind_of(Array)
      end
    end

    should 'clash' do
      app.call(RC::RESPONSE_BODY => {}) do |res|
        body = res[RC::RESPONSE_BODY]
        body.should.kind_of(RC::Clash)
        body.should.empty
        body[0].should.eq({})
        body[0][0].should.eq({})
      end
    end

    describe 'client' do
      body = {0 => {1 => 2}}
      client = RC::Builder.client do
        use RC::ClashResponse, true
        run Class.new{
          define_method(:call) do |env, &block|
            block.call(env.merge(RC::RESPONSE_BODY => body))
          end
        }
      end

      should 'do nothing' do
        b = client.new(:clash_response => false).get(''){ |res|
          res.should.eq(body)
          res.should.kind_of(Hash)
        }.get('')
        b.should.eq(body)
        b.should.kind_of(Hash)
      end

      should 'clash' do
        b = client.new.get(''){ |res|
          res.should.eq(body)
          res.should.kind_of(RC::Clash)
        }.get('')
        b.should.eq(body)
        b.should.kind_of(RC::Clash)
      end
    end
  end
end
