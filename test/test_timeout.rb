
require 'rest-core/test'

describe RC::Timeout do
  after do
    WebMock.reset!
  end

  def setup_app
    RC::Timeout.new(RC::Dry.new, 0)
  end

  should 'bypass timeout if timeout is 0' do
    app = setup_app
    mock(app).monitor.times(0)
    app.call({}){ |e| e.should.eq({}) }
  end

  should 'run the monitor to setup timeout' do
    app = setup_app
    env = {'timeout' => 2}
    mock.proxy(app).monitor(env).times(1)
    app.call(env){ |e| e.should.eq(env) }
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
