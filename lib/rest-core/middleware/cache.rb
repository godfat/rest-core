
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
    e = if env['cache.update']
          cache_clear(env)
        else
          env
        end

    if cached = cache_get(e)
      e[TIMER].cancel if e[TIMER]
      wrapped.call(cached, &k)
    else
      app.call(e){ |res|
        wrapped.call(res){ |res_wrapped|
          k.call(if (res_wrapped[FAIL] || []).empty?
                   cache_for(res).merge(res_wrapped)
                 else
                   res_wrapped
                 end)}}
    end
  end

  def cache_key env
    "rest-core:cache:#{Digest::MD5.hexdigest(env['cache.key'] ||
                                             cache_key_raw(env))}"
  end

  def cache_get env
    return unless cache(env)
    return unless cache_for?(env)

    start_time = Time.now
    return unless data = cache(env)[cache_key(env)]
    log(env, Event::CacheHit.new(Time.now - start_time, request_uri(env))).
      merge(data_extract(data))
  end

  private
  def cache_key_raw env
    "#{env[REQUEST_METHOD]}:#{request_uri(env)}:#{header_cache_key(env)}"
  end

  def cache_clear env
    return env unless cache(env)
    return env unless cache_for?(env)

    cache_store(env, :[]=, nil)
  end

  def cache_for res
    return res unless cache(res)
    return res unless cache_for?(res)

    if expires_in(res).kind_of?(Fixnum) &&
       cache(res).respond_to?(:store)   &&
       cache(res).method(:store).arity == -3

      cache_store(res, :store, data_construct(res),
                                 :expires_in => expires_in(res))
    else
      cache_store(res, :[]=  , data_construct(res))
    end
  end

  def cache_store res, msg, value, *args
    start_time = Time.now
    cache(res).send(msg, cache_key(res), value, *args)

    if value
      res
    else
      log(res,
        Event::CacheCleared.new(Time.now - start_time, request_uri(res)))
    end
  end

  def data_construct res
    "#{ res[RESPONSE_STATUS]}\n" \
    "#{(res[RESPONSE_HEADERS]||{}).map{|k,v|"#{k}: #{v}"}.join("\n")}\n\n" \
    "#{ res[RESPONSE_BODY]}"
  end

  def data_extract data
    _ ,status, headers, body = data.match(/\A(.*)\n(.*)\n\n(.*)\Z/m).to_a
    {RESPONSE_BODY    => body,
     RESPONSE_HEADERS => Hash[(headers||'').scan(/([^:]+): ([^\n]+)\n?/)],
     RESPONSE_STATUS  => status.to_i}
  end

  def cache_for? env
    [:get, :head, :otpions].include?(env[REQUEST_METHOD])
  end

  def header_cache_key env
    (env[REQUEST_HEADERS]||{}).sort.map{|(k,v)|"#{k}=#{v}"}.join('&')
  end
end
