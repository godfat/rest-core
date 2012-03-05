
require 'rest-core/test'

describe RC::FollowRedirect do
  before do
    @dry = RC::Dry.new
    @app = RC::FollowRedirect.new(dry, 1)
  end
  after do
    RR.verify
  end
  def dry; @dry; end
  def app; @app; end

  [301, 302, 303, 307].each do |status|
    should "not follow redirect if reached max_redirects: #{status}" do
      mock(dry).call(anything){ |env|
        env.merge(RC::RESPONSE_STATUS => status,
                  RC::RESPONSE_HEADERS => {'LOCATION' => 'location'})
      }
      app.call(RC::REQUEST_METHOD => :get,
               'max_redirects' => 0)[RC::RESPONSE_HEADERS]['LOCATION'].
                                                 should.eq 'location'
    end

    should "follow once: #{status}" do
      mock(dry).call(anything){ |env|
        env.merge(RC::RESPONSE_STATUS => status,
                  RC::RESPONSE_HEADERS => {'LOCATION' => 'location'})
      }.times(2)
      app.call(RC::REQUEST_METHOD => :get)[RC::RESPONSE_HEADERS]['LOCATION'].
                                                       should.eq 'location'
    end
  end

  [200, 201, 404, 500].each do |status|
    should "not follow redirect if it's not a redirect status: #{status}" do
      mock(dry).call(anything){ |env|
        env.merge(RC::RESPONSE_STATUS => status,
                  RC::RESPONSE_HEADERS => {'LOCATION' => 'location'})
      }
      app.call(RC::REQUEST_METHOD => :get,
               'max_redirects' => 9)[RC::RESPONSE_HEADERS]['LOCATION'].
                                                 should.eq 'location'
    end
  end
end
