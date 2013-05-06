
require 'rest-core/test'

describe RC::EmHttpRequest do
  should 'raise RC::Error' do
    EM.run{Fiber.new{
      lambda{
        RC::Universal.new.get('http://localhost:1').tap{}
      }.should.raise(RC::Error)
      EM.stop
    }.resume}
  end

  should 'never crash EM!' do
    EM.error_handler{ |e| e.should.kind_of?(NoMethodError); EM.stop}
    EM.run{Fiber.new{
      RC::Simple.new.get('http://localhost:1').no_such_method
    }.resume}
  end

  describe 'POST Payload' do
    after do
      WebMock.reset!
    end

    client = RC::Builder.client
    client.builder.run(RC::EmHttpRequest)
    path = 'http://example.com'
    ok   = 'OK'
    c    = client.new

    post = lambda do |payload, body|
      stub_request(:post, path).with(:body => body).to_return(:body => ok)
      EM.error_handler{ |e| e.should.kind_of?(NilClass); EM.stop }
      EM.run{ EM.defer{
        c.post(path, payload).should.eq ok
        EM.next_tick{ EM.stop }
      }}
    end

    should 'post with string' do
      post['string', 'string']
    end

    should 'post with file' do
      File.open(__FILE__) do |f|
        b = f.read
        f.rewind
        post[f, b]
      end
    end

    should 'post with socket' do
      rd, wr = IO.pipe
      wr.write('socket')
      wr.close
      post[rd, 'socket']
    end
  end

  # ----------------------------------------------------------------------

  describe RC::Simple do
    before do
      @path = 'http://example.com'
      stub_request(:get, @path).to_return(:body => 'OK')
    end

    should 'work with EM' do
      EM.run{Fiber.new{
        RC::Simple.new.get(@path).should.eq 'OK'; EM.stop}.resume}
    end
  end

  # ----------------------------------------------------------------------

  describe RC::Timeout do
    after do
      WebMock.reset!
      RR.verify
    end

    should 'cancel timeout for fiber' do
      any_instance_of(RC::Timeout::TimerEm) do |timer|
        proxy.mock(timer).cancel.times(2)
      end
      path = 'http://example.com/'
      stub_request(:get, path).to_return(:body => 'response')
      c = RC::Builder.client do
        use RC::Timeout, 10
        use RC::Cache, {}, 3600
        run RC::EmHttpRequest
      end.new
      EM.run{ Fiber.new{
        c.request(RC::REQUEST_PATH => path).should.eq 'response'
        c.request(RC::REQUEST_PATH => path).should.eq 'response'
        EM.stop }.resume }
      c.cache.size.should.eq 1
    end

    should 'cancel timeout for async' do
      path = 'http://example.com/'
      any_instance_of(RC::Timeout::TimerEm) do |timer|
        mock(timer).cancel.times(2)
      end
      stub_request(:get, path).to_return(:body => 'response')
      c = RC::Builder.client do
        use RC::Timeout, 10
        use RC::Cache, {}, 3600
        run RC::EmHttpRequest
      end.new
      EM.run{
        c.request_full(RC::REQUEST_PATH => path){
          c.request_full(RC::REQUEST_PATH => path){
            EM.stop }}}
      c.cache.size.should.eq 1
    end

    should 'return correct result for futures' do
      path = 'http://example.com/'
      stub_request(:get, path).to_return(:body => 'response')

      c = RC::Builder.client do
        use RC::Timeout, 10
        run RC::EmHttpRequest
      end.new
      EM.run{Fiber.new{c.get(path).should.eq('response');EM.stop}.resume}
    end

    describe 'raise exception' do
      should 'default timeout' do
        c = RC::Builder.client do
          use RC::Timeout, 0.00001
          run Class.new{
            def call env
              sleep 1
              yield(env)
            end
          }
        end.new
        lambda{ c.get('') }.should.raise ::Timeout::Error
      end

      should 'future timeout' do
        port = 35795
        path = "http://localhost:#{port}/"

        c = RC::Builder.client do
          use RC::Timeout, 0.00001
          run RC::EmHttpRequest
        end.new

        EM.run{
          EM.start_server '127.0.0.1', port, Module.new{
            def receive_data data; end
          }
          Fiber.new{
            begin
              c.get(path).tap{}
            rescue => e
              e.should.kind_of ::Timeout::Error
              EM.stop
            end
          }.resume}
      end

      should 'async timeout' do
        port = 35795
        path = "http://localhost:#{port}/"

        c = RC::Builder.client do
          use RC::Timeout, 0.00001
          use RC::ErrorHandler
          run RC::EmHttpRequest
        end.new

        EM.run{
          EM.start_server '127.0.0.1', port, Module.new{
            def receive_data data; end
          }
          c.get(path){ |e| e.should.kind_of ::Timeout::Error; EM.stop }
        }
      end
    end
  end
end unless RUBY_ENGINE == 'jruby'
