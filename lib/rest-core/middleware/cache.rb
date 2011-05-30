
require 'rest-core/event'
require 'rest-core/middleware'

require 'digest/md5'

class RestCore::Cache
  def self.members; [:cache]; end
  include RestCore::Middleware

  attr_reader :middles
  def initialize app, cache, &block
    @app, @cache, @middles = app, cache, []
    instance_eval(&block) if block_given?
  end

  def use middle, *args, &block
    middles << [middle, args, block]
  end

  def to_app init=app
    # === foldr m.new app middles
    middles.reverse.inject(init){ |app_, (middle, args, block)|
      begin
        middle.new(app_, *partial_deep_copy(args), &block)
      rescue ArgumentError => e
        raise ArgumentError.new("#{middle}: #{e}")
      end
    }
  end

  # def call env
  #   cache_get(env) || if (response = app.call(env)) &&
  #                         !(response[FAIL] || []).empty?
  #                       response
  #                     else
  #                       cache_for(env, response)
  #                     end
  # end

  def partial_deep_copy obj
    case obj
      when Array; obj.map{ |o| partial_deep_copy(o) }
      when Hash ; obj.inject({}){ |r, (k, v)| r[k] = partial_deep_copy(v); r }
      when Numeric, Symbol, TrueClass, FalseClass, NilClass; obj
      else begin obj.dup; rescue TypeError; obj; end
    end
  end

  def call env
    if cached = cache_get(env)
      to_app(Ask.new).call(cached)
    else
      response = app.call(env)
      response_ = to_app(Ask.new).call(response)
      if (response_[FAIL] || []).empty?
        cache_for(env, response)
        response_
      else
        response_
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
