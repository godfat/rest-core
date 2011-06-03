
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

  def call env
    e = if env['cache.update'] && env[REQUEST_METHOD] == :get
          cache_assign(env, nil)
        else
          env
        end

    if cached = cache_get(e)
      wrapped.call(cached)
    else
      response         = app.call(e)
      response_wrapped = wrapped.call(response)
      if (response_wrapped[FAIL] || []).empty?
        cache_for(e, response).merge(response_wrapped)
      else
        response_wrapped
      end
    end
  end

  protected
  def cache_key env
    Digest::MD5.hexdigest(env['cache.key'] || request_uri(env))
  end

  def cache_get env
    return unless cache(env)
    start_time = Time.now
    return unless value = cache(env)[cache_key(env)]
    log(env, Event::CacheHit.new(Time.now - start_time, request_uri(env))).
      merge(RESPONSE_BODY => value)
  end

  def cache_for env, response
    return response unless cache(env)
    # fake post (opts[:post] => true) is considered get and need cache
    return response if env[REQUEST_METHOD] != :get unless env['cache.post']

    value = response[RESPONSE_BODY]

    if expires_in(env).kind_of?(Fixnum) &&
       cache(env).method(:store).arity == -3
      cache(env).store(cache_key(env), value,
                       :expires_in => expires_in(env))
      response
    else
      cache_assign(response, value)
    end
  end

  def cache_assign env, value
    return env unless cache(env)

    start_time = Time.now
    cache(env)[cache_key(env)] = value
    if value.nil?
      log(env,
        Event::CacheCleared.new(Time.now - start_time, request_uri(env)))
    else
      env
    end
  end
end
