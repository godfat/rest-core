
require 'socket'
require 'rest-core/test'

describe RC::EventSource do
  client = RC::Builder.client.new
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

  should 'work regularly' do
    es, m, t = server.call
    flag = 0

    es.onopen do |sock|
      sock.should.kind_of IO
      flag.should.eq 0
      flag += 1
    end

    es.onmessage do |event, sock|
      event.should.eq(m.shift)
      sock.should.kind_of IO
      sock.should.not.closed?
      flag += 1
    end

    es.onerror do |error, sock|
      error.should.kind_of EOFError
      m.should.eq []
      sock.should.closed?
      flag.should.eq 3
      flag += 1
    end

    es.start
    es.wait
    flag.should.eq 4
    t.join
  end

  should 'close' do
    es, _, t = server.call(false)
    flag = 0
    es.onmessage do
      es.close
      flag += 1
    end
    es.start
    es.wait
    flag.should.eq 1
    t.join
  end
end
