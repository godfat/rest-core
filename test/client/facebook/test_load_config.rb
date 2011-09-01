
require 'rest-core/test'

require 'rest-core/util/config'
::Rails = Object.new

describe RestCore::Config do

  before do
    @klass = RestCore::Facebook.dup
  end

  after do
    RR.verify
  end

  def check
    @klass.default_app_id     .should == 41829
    @klass.default_secret     .should == 'r41829'.reverse
    @klass.default_json_decode.should == false
    @klass.default_lang       .should == 'zh-tw'
  end

  should 'honor rails config' do
    mock(Rails).env { 'test' }
    mock(Rails).root{ File.dirname(__FILE__) }
    RestCore::Config.load_for_rails(@klass)
    check
  end

  should 'honor config' do
    RestCore::Config.load(
      @klass,
      "#{File.dirname(__FILE__)}/config/rest-core.yaml",
      'test')
    check
  end
end
