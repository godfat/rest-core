
require 'em-http-request'
require 'restclient/payload'

require 'rest-core/engine/future/future'
require 'rest-core/middleware'

class RestCore::EmHttpRequest
  include RestCore::Middleware
  def call env, &k
    future = Future.create(env, k, env[ASYNC])

    # eventmachine is not thread-safe, so...
    # https://github.com/igrigorik/em-http-request/issues/190#issuecomment-16995528
    ::EventMachine.schedule{ request(future, env) }

    env.merge(RESPONSE_BODY    => future.proxy_body,
              RESPONSE_STATUS  => future.proxy_status,
              RESPONSE_HEADERS => future.proxy_headers,
              FUTURE           => future)
  end

  def close client, tmpfile
    (client.instance_variable_get(:@callbacks)||[]).clear
    (client.instance_variable_get(:@errbacks )||[]).clear
    client.close
    if tmpfile.respond_to?(:close!)   # tempfile
      tmpfile.close!
    elsif tmpfile.respond_to?(:close) # regular IO
      tmpfile.close
    end
  end

  def request future, env
    payload = Payload.generate(env[REQUEST_PAYLOAD])
    tmpfile = payload2file(payload)
    args    = if tmpfile.nil?
                {}
              elsif tmpfile.respond_to?(:path)
                {:file => tmpfile.path}
              else
                {:body => tmpfile}
              end
    client  = ::EventMachine::HttpRequest.new(request_uri(env)).send(
                 env[REQUEST_METHOD], args.merge(
                   :head => env[REQUEST_HEADERS].merge(payload.headers)))

    client.callback{
      close(client, tmpfile)
      future.on_load(client.response,
                     client.response_header.status,
                     client.response_header)}

    client.errback{
      close(client, tmpfile)
      future.on_error(client.error)}

    env[TIMER].on_timeout{
      close(client, tmpfile)
      future.on_error(env[TIMER].error)
    } if env[TIMER]
  end

  def payload2file payload
    if payload.io.nil?                  # no payload
      nil

    elsif payload.io.respond_to?(:path) # already a file
      payload.io

    elsif payload.size == 0 ||       # probably a socket, buffer to disc
          payload.size >= 81920      # probably too large, buffer to disc
      create_tmpfile(payload.io)

    else                             # probably not worth buffering to disc
      payload.read
    end
  end

  def create_tmpfile io
    tempfile = Tempfile.new("rest-core.em-http-request.#{rand(1_000_000)}")
    IO.copy_stream(io, tempfile)
    tempfile
  end
end
