
require 'rest-core/test'

describe RC::Universal do
  url = 'http://localhost:1'

  after do
    WebMock.reset!
  end

  # TODO: RuntimeError: The request GET http://localhost:1/ with body nil was expected to execute 1 time but it executed 2 times
  would 'only send payload for post, put, patch' do
    c = RC::Universal.new(:log_method => false, :payload => '$payload')
    [:get, :head, :options].each do |method|
      stub_request(method, url)
      c.send(method, url).tap{}
      assert_requested(method, url, :body => nil)
    end

    [:put, :post, :patch, :delete].each do |method|
      stub_request(method, url).with(:body => '$payload')
      c.send(method, url).tap{}
      assert_requested(method, url, :body => '$payload')
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
