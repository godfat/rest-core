
require 'rest-core'

require 'pork/auto'
require 'muack'
require 'webmock'

# for testing lighten (serialization)
require 'yaml'

WebMock.disable_net_connect!(:allow_localhost => true)
Pork::Executor.__send__(:include, Muack::API, WebMock::API)

class Pork::Executor
  def with_img
    f = Tempfile.new(['img', '.jpg'])
    n = File.basename(f.path)
    f.write('a'*10)
    f.rewind
    yield(f, n)
  ensure
    f.close!
  end

  def mock_warning
    mock(any_instance_of(RC::Promise)).warn(is_a(String)) do |msg|
      msg.should.include?(Errno::ECONNREFUSED.new.message)
    end
  end
end
