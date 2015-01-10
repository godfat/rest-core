
require 'rest-core/test'
require 'rest-core/engine'

describe RC::Timeout do
  app = RC::Timeout.new(RC::Dry.new, 0)

  after do
    WebMock.reset!
    Muack.verify
  end

  would 'bypass timeout if timeout is 0' do
    mock(app).process.times(0)
    app.call({}){ |e| e.should.eq({}) }
  end

  would 'run the process to setup timeout' do
    env = {'timeout' => 2}
    mock(app).process(env)
    app.call(env){|e| e[RC::TIMER].should.kind_of?(RC::Timer)}
  end

  would "not raise timeout error if there's already an error" do
    env = {'timeout' => 0.01}
    mock(app.app).call(hash_including(env)){ raise "error" }
    lambda{ app.call(env){} }.should    .raise(RuntimeError)
    lambda{ sleep 0.01      }.should.not.raise(Timeout::Error)
  end

  def fake_timer
    Object.new.instance_eval do
      @block = nil
      def on_timeout; @block = true; Thread.new{yield}; end
      def error     ; 'boom'; end
      def cancel    ;       ; end
      def timer     ; @block; end
      self
    end
  end

  def sleeping_app
    RC::Builder.client do
      run Class.new(RC::Engine){
        def request _, _
          sleep
        end
      }
    end
  end

  would 'cancel the task if timing out for thread pool' do
    timer = fake_timer
    app   = sleeping_app
    app.pool_size = 1
    app.new.request(RC::TIMER => timer, RC::ASYNC => true).
      message.should.eq 'boom'
    timer.timer.should.not.nil?
  end

  would 'still timeout if the task never processed for thread pool' do
    app = sleeping_app
    app.pool_size = 1
    app.new.request(RC::TIMER => fake_timer, RC::ASYNC => true) do |e|
      e.message.should.eq 'boom'
      app.new.request(RC::TIMER => fake_timer, RC::ASYNC => true).tap{}
    end
    app.wait
  end

  would 'interrupt the task if timing out' do
    rd, wr = IO.pipe
    timer = Object.new.instance_eval do
      @block = nil
      define_singleton_method :on_timeout do |&block|
        @block = block
        Thread.new do
          rd.gets
          block.call
          @block = nil
        end
      end
      def error     ; 'boom'; end
      def cancel    ;       ; end
      def timer     ; @block; end
      self
    end
    app = RC::Builder.client do
      run Class.new(RC::Engine){
        def request _, env
          env['pipe'].puts
          sleep
        end
      }
    end
    (-1..1).each do |size|
      app.pool_size = size
      app.new.request(RC::TIMER => timer, RC::ASYNC => true, 'pipe' => wr).
        message.should.eq 'boom'
    end
  end
end
