
require 'thread'
require 'rest-core'

class RestCore::EventSource < Struct.new(:client, :path, :query, :opts,
                                         :socket)
  include RestCore
  def start
    self.mutex = Mutex.new
    self.condv = ConditionVariable.new
    @onopen        ||= nil
    @onmessage_for ||= nil
    @onerror       ||= nil

    client.request(
      {REQUEST_METHOD  => :get ,
       REQUEST_PATH    => path ,
       REQUEST_QUERY   => query,
       REQUEST_HEADERS => {'Accept' => 'text/event-stream'},
       HIJACK          => true }.merge(opts), RESPONSE_SOCKET) do |sock|

      onopen(sock)
    end
  end

  def closed?
    !!(socket && socket.closed?)
  end

  def close
    socket && socket.close
  rescue IOError
  end

  def wait
    raise RC::Error.new("Not yet started for: #{self}") unless mutex
    mutex.synchronize{ condv.wait(mutex) until closed? } unless closed?
  end

  def onopen sock=nil, &cb
    if block_given?
      @onopen = cb
    else
      @onopen.call(sock) if @onopen
      onmessage_for(sock)
    end
  rescue Exception => e
    begin # close the socket since we're going to stop anyway
      sock.close # if we don't close it, client might wait forever
    rescue IOError
    end
    # let the client has a chance to handle this, and make signal
    onerror(e, sock)
  end

  def onmessage event=nil, sock=nil, &cb
    if block_given?
      @onmessage = cb
    elsif @onmessage
      @onmessage.call(event, sock)
    end
  end

  # would also be called upon closing, would always be called at least once
  def onerror error=nil, sock=nil, &cb
    if block_given?
      @onerror = cb
    else
      begin
        @onerror.call(error, sock) if @onerror
      ensure
        condv.signal # should never deadlock someone
      end
    end
  end

  protected
  attr_accessor :mutex, :condv

  private
  # called in requesting thread after the request is done
  def onmessage_for sock
    self.socket = sock # for you to track the socket
    until sock.eof?
      event = sock.readline("\n\n").split("\n").inject({}) do |r, i|
        k, v = i.split(': ', 2)
        r[k] = v
        r
      end
      onmessage(event, sock)
    end
    sock.close
    onerror(EOFError.new, sock)
  rescue IOError => e
    onerror(e, sock)
  end
end
