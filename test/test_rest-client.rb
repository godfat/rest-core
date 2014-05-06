
require 'rest-core/test'

describe RC::RestClient do
  describe 'POST Payload' do
    after do
      WebMock.reset!
    end

    client = RC::Builder.client
    client.builder.run(RC::RestClient)
    path = 'http://example.com'
    ok   = 'OK'
    c    = client.new

    post = lambda do |payload, body|
      stub_request(:post, path).with(:body => body).to_return(:body => ok)
      c.post(path, payload).should.eq ok
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

    should 'not kill the thread if error was coming from the task' do
      mock(RestClient::Request).execute{ raise 'boom' }.with_any_args
      c.request(RC::RESPONSE_KEY => RC::FAIL).first.message.should.eq 'boom'
      Muack.verify
    end

    should 'cancel the task if timing out' do
      timer = Object.new.instance_eval do
        def on_timeout; yield ; end
        def error     ; 'boom'; end
        def cancel    ;       ; end
        self
      end
      stub(c.class).pool_size{ 1 }
      stub(c.class.thread_pool).queue{ [] } # don't queue the task
      mock(RC::ThreadPool::Task).new.with_any_args.
        peek_return{ |t| mock(t).cancel; t } # the task should be cancelled
      c.request(RC::RESPONSE_KEY => RC::FAIL, RC::TIMER => timer).
        first.message.should.eq 'boom'
      Muack.verify
    end
  end
end
