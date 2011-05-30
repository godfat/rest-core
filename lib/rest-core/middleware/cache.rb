
require 'rest-core/event'
require 'rest-core/middleware'
require 'rest-core/wrapper'

require 'digest/md5'

class RestCore::Cache
  def self.members; [:cache]; end
  include RestCore::Middleware
  include RestCore::Wrapper

  attr_reader :wrapped
  def initialize app, cache, &block
    super(&block)
    @app, @cache, @wrapped = app, cache, to_app(Ask)
  end

  def call env
    if cached = cache_get(env)
      wrapped.call(cached)
    else
      response         = app.call(env)
      response_wrapped = wrapped.call(response)
      cache_for(env, response) if (response_wrapped[FAIL] || []).empty?
      response_wrapped
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
      merge(value)
  end

  def cache_for env, response
    return response unless cache(env)
    # fake post (opts[:post] => true) is considered get and need cache
    return response if env[REQUEST_METHOD] != :get unless env['cache.post']

    value = response.select{ |k,v| k.start_with?('RESPONSE') }

    if env['cache.expires_in'].kind_of?(Fixnum) &&
       cache(env).method(:store).arity == -3
      cache(env).store(cache_key(env), value,
                       :expires_in => env['cache.expires_in'])
    else
      cache_assign(env, value)
    end

    response
  end

  def cache_assign env, value
    return value unless cache(env)

    start_time = Time.now
    cache(env)[cache_key(env)] = value
    if value.nil?
      log(env,
        Event::CacheCleared.new(Time.now - start_time, request_uri(env)))
    end
    value
  end
end
