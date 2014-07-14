
require 'socket'
require 'rest-core/test'

describe RC::EventSource do
  after do
    WebMock.reset!
  end

  client = RC::Builder.client{use RC::Cache, {}, nil}.new
  server = lambda do |close=true|
    serv = TCPServer.new(0)
    port = serv.addr[1]
    path = "http://localhost:#{port}/"
    payload = <<-SSE
event: put
data: {}

event: keep-alive
data: null
SSE
    m = [{'event' => 'put'       , 'data' => '{}'},
         {'event' => 'keep-alive', 'data' => 'null'}]

    t = Thread.new do
      sock = serv.accept
      sock.readline("\r\n\r\n")
      sock.puts("HTTP/1.1 200 OK\r")
      sock.puts("Content-Type: text/event-stream\r")
      sock.puts
      sock.puts(payload)
      sock.close if close
    end

    [client.event_source(path, :a => 'b'), m, t]
  end

  would 'work regularly' do
    es, m, t = server.call
    flag = 0

    es.onopen do |sock|
      sock.should.kind_of? IO
      flag.should.eq 0
      flag += 1
    end.
    onmessage do |event, data, sock|
      {'event' => event, 'data' => data}.should.eq m.shift
      sock.should.kind_of? IO
      sock.should.not.closed?
      flag += 1
    end.
    onerror do |error, sock|
      error.should.kind_of? EOFError
      m.should.empty?
      sock.should.closed?
      flag.should.eq 3
      flag += 1
    end.start.wait

    flag.should.eq 4
    t.join
  end

  would 'close' do
    es, _, t = server.call(false)
    flag = 0
    es.onmessage do
      es.close
      flag += 1
    end.start.wait

    flag.should.eq 1
    t.join
  end

  would 'reconnect' do
    stub_request(:get, 'https://a?b=c').to_return(:body => <<-SSE)
event: put
data: 0

event: put
data: 1
SSE
    stub_request(:get, 'https://a?c=d').to_return(:body => <<-SSE)
event: put
data: 2

event: put
data: 3
SSE
    es = client.event_source('https://a', :b => 'c')
    m = ('0'..'3').to_a
    es.onmessage do |event, data|
      data.should.eq m.shift

    end.onerror do |error|
      error.should.kind_of? EOFError
      es.query = {:c => 'd'}

    end.onreconnect do |error, sock|
      error.should.kind_of? EOFError
      sock.should.respond_to? :read
      !m.empty? # not empty to reconnect

    end.start.wait
    m.should.empty?
  end

  would 'not cache' do
    stub_request(:get, 'https://a?b=c').to_return(:body => <<-SSE)
event: put
data: 0

event: put
data: 1
SSE
    es = client.event_source('https://a', :b => 'c')
    m = %w[0 1 0 1]
    es.onmessage do |event, data|
      data.should.eq m.shift

    end.onerror do |error|
      error.should.kind_of? EOFError

    end.onreconnect do |error, sock|
      error.should.kind_of? EOFError
      sock.should.respond_to? :read
      !m.empty? # not empty to reconnect

    end.start.wait
    m.should.empty?
  end
end
