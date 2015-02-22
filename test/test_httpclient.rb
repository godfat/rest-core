
require 'rest-core/test'

require 'openssl'
require 'socket'
require 'zlib'

describe RC::HttpClient do
  describe 'POST Payload' do
    after do
      WebMock.reset!
    end

    client = RC::Builder.client
    path = 'http://example.com'
    ok   = 'OK'
    c    = client.new

    post = lambda do |payload, body|
      WebMock::API.stub_request(:post, path).
        with(:body => body).to_return(:body => ok)
      c.post(path, payload).should.eq ok
    end

    would 'post with string' do
      post['string', 'string']
    end

    would 'post with file' do
      File.open(__FILE__) do |f|
        b = f.read
        f.rewind
        post[f, b]
      end
    end

    would 'post with socket' do
      rd, wr = IO.pipe
      wr.write('socket')
      wr.close
      post[rd, 'socket']
    end

    would 'not kill the thread if error was coming from the task' do
      mock(HTTPClient).new{ raise 'boom' }.with_any_args
      c.request(RC::ASYNC => true).message.should.eq 'boom'
      Muack.verify
    end

    def accept body
      server = TCPServer.new(0)
      t = Thread.new do
        client = server.accept
        client.write(<<-HTTP)
HTTP/1.0 200 OK\r
Connection: close\r
Content-Encoding: deflate\r
\r
#{body}\r
          HTTP
        client.close_write
      end

      yield("http://localhost:#{server.local_address.ip_port}")

      t.join
    end

    would 'accept deflate' do
      accept(Zlib::Deflate.deflate(ok)) do |site|
        c.post(site, 'body').should.eq ok
      end
    end

    config_engine = lambda do |engine|
      engine.transparent_gzip_decompression = false
      engine.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    define_method(:define_default_config_engine) do |d|
      d.singleton_class.module_eval do
        define_method(:default_config_engine) do
          config_engine
        end
      end
    end

    would 'disable auto-deflate' do
      accept(ok) do |site|
        c.post(site, 'body', {}, :config_engine => config_engine).
          chomp.should.eq ok
      end
    end

    would 'disable auto-deflate with class default_config_engine' do
      accept(ok) do |site|
        d = RC::Builder.client
        define_default_config_engine(d)
        d.new.post(site, 'body').chomp.should.eq ok
      end
    end

    would 'disable auto-deflate with instance default_config_engine' do
      accept(ok) do |site|
        d = RC::Builder.client.new
        define_default_config_engine(d)
        d.post(site, 'body').chomp.should.eq ok
      end
    end

    would 'disable auto-deflate with setting config_engine' do
      accept(ok) do |site|
        d = RC::Builder.client.new(:config_engine => config_engine)
        d.post(site, 'body').chomp.should.eq ok
      end
    end
  end
end
