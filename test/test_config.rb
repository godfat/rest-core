
require 'rest-core/test'

describe RC::Config do
  before do
    @klass = RC::Builder.client
  end

  after do
    Muack.verify
  end

  def check
    @klass.default_app_id       .should.eq 41829
    @klass.default_secret       .should.eq 'r41829'.reverse
    @klass.default_json_response.should.eq false
    @klass.default_lang         .should.eq 'zh-tw'
  end

  would 'honor config' do
    RC::Config.load(
      @klass,
      "#{File.dirname(__FILE__)}/config/rest-core.yaml",
      'test',
      'facebook')
    check
  end
end
