
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestGraph do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'return true in authorized? if there is an access_token' do
    RestGraph.new(:access_token => '1').authorized?.should == true
    RestGraph.new(:access_token => nil).authorized?.should == false
  end

  should 'treat oauth_token as access_token as well' do
    rg = RestGraph.new
    hate_facebook = 'why the hell two different name?'
    rg.data['oauth_token'] = hate_facebook
    rg.authorized?.should == true
    rg.access_token       == hate_facebook
  end

  should 'build correct headers' do
    rg = RestGraph.new(:accept => 'text/html',
                       :lang   => 'zh-tw')

    headers = rg.ask.call(rg.send(:build_env))[RestCore::REQUEST_HEADERS]
    headers['Accept'         ].should == 'text/html'
    headers['Accept-Language'].should == 'zh-tw'
  end

  should 'build empty query string' do
    rg = RestGraph.new
    (rg.ask.call(rg.send(:build_env))[RestCore::REQUEST_QUERY] || {}).
      should == {}
  end

  should 'create access_token in query string' do
    rg = RestGraph.new(:access_token => 'token')
    (rg.ask.call(rg.send(:build_env))[RestCore::REQUEST_QUERY] || {}).
      should == {'access_token' => 'token'}
  end

  should 'build correct query string' do
    rg = RestGraph.new(:access_token => 'token')
    TestHelper.normalize_url(rg.url('', :message => 'hi!!')).
      should == "#{rg.site}?access_token=token&message=hi%21%21"

    rg.access_token = nil
    TestHelper.normalize_url(rg.url('', :message => 'hi!!',
                                        :subject => '(&oh&)')).
      should == "#{rg.site}?message=hi%21%21&subject=%28%26oh%26%29"
  end

  should 'auto decode json' do
    rg = RestGraph.new(:auto_decode => true)
    stub_request(:get, rg.site).to_return(:body => '[]')
    rg.get('').should ==  []
  end

  should 'not auto decode json' do
    rg = RestGraph.new(:auto_decode => false)
    stub_request(:get, rg.site).to_return(:body => '[]')
    rg.get('').should == '[]'
  end

  should 'give attributes' do
    RestGraph.new(:auto_decode => false).attributes.keys.map(&:to_s).sort.
      should == RestGraph.members.map(&:to_s).sort
  end
end
