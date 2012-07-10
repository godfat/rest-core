
require 'rest-core/test'

describe RC::FollowRedirect do
  before do
    @dry = Class.new do
      attr_accessor :status
      def call env
        yield(env.merge(RC::RESPONSE_STATUS  => status,
                        RC::RESPONSE_HEADERS => {'LOCATION' => 'location'}))
      end
    end.new
    @app = RC::FollowRedirect.new(dry, 1)
  end
  after do
    RR.verify
  end
  def dry; @dry; end
  def app; @app; end

  [301, 302, 303, 307].each do |status|
    should "not follow redirect if reached max_redirects: #{status}" do
      dry.status = status
      app.call(RC::REQUEST_METHOD => :get, 'max_redirects' => 0){ |res|
        res[RC::RESPONSE_HEADERS]['LOCATION'].should.eq 'location'
      }
    end

    should "follow once: #{status}" do
      dry.status = status
      app.call(RC::REQUEST_METHOD => :get){ |res|
        res[RC::RESPONSE_HEADERS]['LOCATION'].should.eq 'location'
      }
    end
  end

  [200, 201, 404, 500].each do |status|
    should "not follow redirect if it's not a redirect status: #{status}" do
      dry.status = status
      app.call(RC::REQUEST_METHOD => :get, 'max_redirects' => 9){ |res|
        res[RC::RESPONSE_HEADERS]['LOCATION'].should.eq 'location'
      }
    end
  end
end
