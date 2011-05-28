
require 'rest-core/event'
require 'rest-core/middleware'

require 'digest/md5'

class RestCore::Cache
  def self.members; [:cache]; end
  include RestCore::Middleware

  def call env
    cache_get(env) || cache_for(env, app.call(env))
  end

  def fail env
    cache_assign(env, nil)
    app.fail(env)
  end

  protected
  def cache_key env
    Digest::MD5.hexdigest(env['cache.key'] || request_uri(env))
  end

  def cache_get env
    return unless cache(env)
    start_time = Time.now
    return unless value = cache(env)[cache_key(env)]
    log(env, Event::CacheHit.new(Time.now - start_time, request_uri(env)))
    env.merge(value)
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
