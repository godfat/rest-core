
require 'rest-core/test'

describe RestCore::Facebook do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'return true in authorized? if there is an access_token' do
    RestCore::Facebook.new(:access_token => '1').authorized?.should.eq true
    RestCore::Facebook.new(:access_token => nil).authorized?.should.eq false
  end

  should 'treat oauth_token as access_token as well' do
    rg = RestCore::Facebook.new
    hate_facebook = 'why the hell two different name?'
    rg.data['oauth_token'] = hate_facebook
    rg.authorized?.should.eq true
    rg.access_token.should.eq hate_facebook
  end

  should 'build correct headers' do
    rg = RestCore::Facebook.new(:accept => 'text/html',
                                :lang   => 'zh-tw')

    headers = rg.dry.call(rg.send(:build_env))[RestCore::REQUEST_HEADERS]
    headers['Accept'         ].should.eq 'text/html'
    headers['Accept-Language'].should.eq 'zh-tw'
  end

  should 'build empty query string' do
    rg = RestCore::Facebook.new
    (rg.dry.call(rg.send(:build_env))[RestCore::REQUEST_QUERY] || {}).
      should.eq({})
  end

  should 'create access_token in query string' do
    rg = RestCore::Facebook.new(:access_token => 'token')
    (rg.dry.call(rg.send(:build_env))[RestCore::REQUEST_QUERY] || {}).
      should.eq({'access_token' => 'token'})
  end

  should 'build correct query string' do
    rg = RestCore::Facebook.new(:access_token => 'token')
    TestHelper.normalize_url(rg.url('', :message => 'hi!!')).
      should.eq "#{rg.site}?access_token=token&message=hi%21%21"

    rg.access_token = nil
    TestHelper.normalize_url(rg.url('', :message => 'hi!!',
                                        :subject => '(&oh&)')).
      should.eq "#{rg.site}?message=hi%21%21&subject=%28%26oh%26%29"
  end

  should 'auto decode json' do
    rg = RestCore::Facebook.new(:json_decode => true)
    stub_request(:get, rg.site).to_return(:body => '[]')
    rg.get('').should.eq []
  end

  should 'not auto decode json' do
    rg = RestCore::Facebook.new(:json_decode => false)
    stub_request(:get, rg.site).to_return(:body => '[]')
    rg.get('').should.eq '[]'
  end

  should 'give attributes' do
    RestCore::Facebook.new(:json_decode => false).attributes.
      keys.map(&:to_s).sort.should.eq \
      RestCore::Facebook.members.map(&:to_s).sort
  end
end
