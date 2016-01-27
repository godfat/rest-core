
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

  def stub_select_for_stringio
    stub(IO).select(where([is_a(StringIO)]), [], [],
                    RestCore::EventSource::READ_WAIT){ |rd, *| rd }
  end
end
