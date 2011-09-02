
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
    @klass.default_app_id     .should.eq 41829
    @klass.default_secret     .should.eq 'r41829'.reverse
    @klass.default_json_decode.should.eq false
    @klass.default_lang       .should.eq 'zh-tw'
  end

  should 'honor rails config' do
    mock(Rails).env { 'test' }
    mock(Rails).root{ File.dirname(__FILE__) }
    RestCore::Config.load_for_rails(@klass, 'facebook')
    check
  end

  should 'honor config' do
    RestCore::Config.load(
      @klass,
      "#{File.dirname(__FILE__)}/config/rest-core.yaml",
      'test',
      'facebook')
    check
  end
end
