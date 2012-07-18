
require 'rest-core/event'
require 'rest-core/middleware'
require 'rest-core/wrapper'

require 'digest/md5'

class RestCore::Cache
  def self.members; [:cache, :expires_in]; end
  include RestCore::Middleware
  include RestCore::Wrapper

  def initialize app, cache, expires_in, &block
    super(&block)
    @app, @cache, @expires_in = app, cache, expires_in
  end

  def call env, &k
    e = if env['cache.update'] && cache_for?(env)
          cache_assign(env, :[]=)
        else
          env
        end

    if cached = cache_get(e)
      e[TIMER].cancel if e[TIMER]
      wrapped.call(cached, &k)
    else
      app.call(e){ |res| process(res, k) }
    end
  end

  def cache_key env
    Digest::MD5.hexdigest(env['cache.key'] || request_uri(env))
  end

  def cache_key_body env
    "#{env[REQUEST_METHOD]}:#{RESPONSE_BODY}:#{cache_key(env)}"
  end

  def cache_key_headers env
    "#{env[REQUEST_METHOD]}:#{RESPONSE_HEADERS}:#{cache_key(env)}"
  end

  def cache_key_status env
    "#{env[REQUEST_METHOD]}:#{RESPONSE_STATUS}:#{cache_key(env)}"
  end

  def cache_get env
    return unless cache(env)
    start_time = Time.now
    return unless body = cache_body(env)
    log(env, Event::CacheHit.new(Time.now - start_time, request_uri(env))).
      merge(RESPONSE_BODY    => body,
            RESPONSE_HEADERS => cache_headers(env),
            RESPONSE_STATUS  => cache_status(env))
  end

  private
  def process res, k
    wrapped.call(res){ |res_wrapped|
      k.call(process_wrapped(res, res_wrapped))
    }
  end

  def process_wrapped res, res_wrapped
    if (res_wrapped[FAIL] || []).empty?
      cache_for(res).merge(res_wrapped)
    else
      res_wrapped
    end
  end

  def cache_for res
    return res unless cache(res)
    return res unless cache_for?(res)

    if expires_in(res).kind_of?(Fixnum) &&
       cache(res).respond_to?(:store)   &&
       cache(res).method(:store).arity == -3

      cache_store(res, :store, :expires_in => expires_in(res))
    else
      cache_store(res, :[]=)
    end
  end

  def cache_assign env, msg, body=nil, headers=nil, status=nil, *args
    start_time = Time.now
    cache(env).send(msg, cache_key_body(   env), body   , *args)
    cache(env).send(msg, cache_key_headers(env), headers, *args)
    cache(env).send(msg, cache_key_status( env), status , *args)
    if body
      env
    else
      log(env,
        Event::CacheCleared.new(Time.now - start_time, request_uri(env)))
    end
  end

  def cache_store env, msg, *args
    return env unless cache(env)
    return env unless env[RESPONSE_STATUS]
    cache_assign(env, msg, env[RESPONSE_BODY],
      (env[RESPONSE_HEADERS]||{}).map{|k,v|"#{k}: #{v}"}.join("\n"),
       env[RESPONSE_STATUS].to_s, *args)
  end

  def cache_for? env
    [:get, :head, :otpions].include?(env[REQUEST_METHOD])
  end

  def cache_body env
    cache(env)[cache_key_body(env)]
  end

  def cache_headers env
    Hash[cache(env)[cache_key_headers(env)].scan(/([^:]+): ([^\n]+)\n?/)]
  end

  def cache_status env
    cache(env)[cache_key_status(env)].to_i
  end
end
