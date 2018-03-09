
require 'rest-core/test'

describe RC::Universal do
  url = 'http://localhost:1'

  after do
    WebMock.reset!
  end

  would 'only send payload when there is something' do
    m = [:get, :head, :options, :put, :post, :patch, :delete]
    c = RC::Universal.new(:log_method => false, :payload => '$payload')
    m.each do |method|
      stub_request(method, url)
      c.send(method, url).tap{}
      assert_requested(method, url, :body => '$payload')
    end

    c = RC::Universal.new(:log_method => false)
    m.each do |method|
      stub_request(method, url).with(:body => nil)
      c.send(method, url).tap{}
      assert_requested(method, url, :body => nil)
    end
    ok
  end

  would 'send Authorization header' do
    u = RC::Universal.new(:log_method => false)
    u.username = 'Aladdin'
    u.password = 'open sesame'

    u.request_full({}, u.dry)[RC::REQUEST_HEADERS].should.eq(
      {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='})

    acc = {'Accept' => 'text/plain'}
    env = {RC::REQUEST_HEADERS => acc}

    u.request_full(env, u.dry)[RC::REQUEST_HEADERS].should.eq(
      {'Authorization' => 'Basic QWxhZGRpbjpvcGVuIHNlc2FtZQ=='}.merge(acc))
  end

  would 'clash' do
    stub_request(:get, url).to_return(:body => '{"a":{"b":"c"}}')
    res = RC::Universal.new(:json_response => true,
                            :clash_response => true,
                            :log_method => false).get(url)
    res['a']['d'].should.eq({})
  end

  would 'follow redirect regardless response body' do
    called = []
    stub_request(:get, url).to_return(:body => 'bad json!',
      :status => 302, :headers => {'Location' => "#{url}/a"})
    stub_request(:get, "#{url}/a").to_return do
      Thread.pass
      {:body => '{"good":"json!"}'}
    end
    RC::Universal.new(:json_response => true, :log_method => false).
      get(url, &called.method(:<<)).wait
    called.should.eq([{'good' => 'json!'}])
  end

  would 'retry and call error_callback' do
    errors = []
    called = []
    RC::Universal.new(:error_callback => errors.method(:<<),
                      :max_retries => 1, :log_method => false).
      get(url, &called.method(:<<)).wait

    expect(errors.size).eq 2
    errors.all?{ |err| expect(is_a(SystemCallError)).match(err) }
    expect(called.size).eq 1
    called.all?{ |err| expect(is_a(SystemCallError)).match(err) }
  end

  would 'not deadlock with ErrorHandler' do
    c = RC::Universal.new(:log_method => false).
               event_source('http://localhost:1')
    c.onerror{ |e| e.should.kind_of?(SystemCallError) }
    c.start.wait
  end
end
