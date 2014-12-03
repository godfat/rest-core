
require 'rest-core/test'

describe RC::FollowRedirect do
  dry = Class.new do
    attr_accessor :status
    def call env
      yield(env.merge(RC::RESPONSE_STATUS  => status,
                      RC::RESPONSE_HEADERS => {'LOCATION' => 'location'}))
      env
    end
  end.new
  app = RC::FollowRedirect.new(dry, 1)

  after do
    Muack.verify
  end

  [301, 302, 303, 307].each do |status|
    would "not follow redirect if reached max_redirects: #{status}" do
      dry.status = status
      app.call(RC::REQUEST_METHOD => :get, 'max_redirects' => 0) do |res|
        res[RC::RESPONSE_HEADERS]['LOCATION'].should.eq 'location'
      end
    end

    would "follow once: #{status}" do
      dry.status = status
      app.call(RC::REQUEST_METHOD => :get) do |res|
        res[RC::RESPONSE_HEADERS]['LOCATION'].should.eq 'location'
      end
    end

    would "not carry query string: #{status}" do
      dry.status = status
      app.call(RC::REQUEST_METHOD => :get,
               RC::REQUEST_QUERY => {:a => 'a'}) do |res|
        res[RC::REQUEST_PATH] .should.eq 'location'
        res[RC::REQUEST_QUERY].should.empty?
      end
    end

    would "carry payload for #{status}" do
      dry.status = status
      app.call(RC::REQUEST_METHOD => :put,
               RC::REQUEST_PAYLOAD => {:a => 'a'}) do |res|
        res[RC::REQUEST_PAYLOAD].should.eq(:a => 'a')
      end
    end if status != 303
  end

  [200, 201, 404, 500].each do |status|
    would "not follow redirect if it's not a redirect status: #{status}" do
      dry.status = status
      app.call(RC::REQUEST_METHOD => :get, 'max_redirects' => 9) do |res|
        res[RC::RESPONSE_HEADERS]['LOCATION'].should.eq 'location'
      end
    end
  end
end
