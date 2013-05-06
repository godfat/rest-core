
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
  end
end
