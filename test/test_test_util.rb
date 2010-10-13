
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

require 'rest-graph/test_util'

describe RestGraph::TestUtil do
  before do
    RestGraph::TestUtil.setup
  end

  after do
    RestGraph::TestUtil.teardown
  end

  should 'stub requests and store result and teardown do cleanup' do
    RestGraph.new.get('me') .should == {'data' => []}
    RestGraph::TestUtil.gets.should ==
      [["https://graph.facebook.com/me", nil]]

    RestGraph::TestUtil.teardown

    RestGraph::TestUtil.gets.should == []
    begin
      RestGraph.new.get('me')
    rescue => e
      e.should.kind_of?(WebMock::NetConnectNotAllowedError)
    end
  end

  should 'override default response' do
    default = {'meta' => []}
    RestGraph::TestUtil.default_response = default
    RestGraph.new.get('me')     .should == default
  end

  should 'have default data' do
    rg = RestGraph.new
    rg.data['uid']           .should == 1234
    RestGraph::TestUtil.default_data  = {'uid' => 4321}
    rg.data['uid']           .should == 4321
    RestGraph.new.data['uid'].should == 4321
  end
end
