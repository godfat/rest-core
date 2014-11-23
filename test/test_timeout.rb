
require 'rest-core/test'
require 'rest-core/engine'

describe RC::Timeout do
  app = RC::Timeout.new(RC::Dry.new, 0)

  after do
    WebMock.reset!
    Muack.verify
  end

  would 'bypass timeout if timeout is 0' do
    mock(app).monitor.times(0)
    app.call({}){ |e| e.should.eq({}) }
  end

  would 'run the monitor to setup timeout' do
    env = {'timeout' => 2}
    mock(app).monitor(env)
    app.call(env){|e| e[RC::TIMER].should.kind_of?(RC::Timer)}
  end

  would "not raise timeout error if there's already an error" do
    env = {'timeout' => 0.01}
    mock(app.app).call(hash_including(env)){ raise "error" }
    lambda{ app.call(env){} }.should    .raise(RuntimeError)
    lambda{ sleep 0.01      }.should.not.raise(Timeout::Error)
  end

  would 'cancel the task if timing out' do
    timer = Object.new.instance_eval do
      def on_timeout; yield ; end
      def error     ; 'boom'; end
      def cancel    ;       ; end
      self
    end
    app = RC::Builder.client do
      run Class.new(RC::Engine){
        def request _, _
          sleep
        end
      }
    end
    app.pool_size = 1
    app.new.request(RC::RESPONSE_KEY => RC::FAIL, RC::TIMER => timer).
      first.message.should.eq 'boom'
    Muack.verify
  end
end
