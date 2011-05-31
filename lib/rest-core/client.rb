
require 'rest-core'

module RestCore::Client
  include RestCore
  def self.included mod
    # honor default attributes
    src = mod.members.map{ |name|
      <<-RUBY
        def #{name}
          if (r = super).nil?
            self.#{name} = default_#{name}
          else
            r
          end
        end

        def default_#{name} app=app
          if app.respond_to?(:#{name})
            app.#{name}({})
          elsif app.respond_to?(:wrapped)
            default_#{name}(app.wrapped) ||
            default_#{name}(app.app)
          elsif app.respond_to?(:app)
            default_#{name}(app.app)
          else
            nil
          end
        end
        private :default_#{name}

        self
      RUBY
    }
    # if RUBY_VERSION < '1.9.2'
    src << <<-RUBY if mod.members.first.kind_of?(String)
      def members
        super.map(&:to_sym)
      end
      self
    RUBY
    # end
    accessor = Module.new.module_eval(src.join("\n"), __FILE__, __LINE__)
    mod.const_set('Accessor', accessor)
    mod.send(:include, accessor)
  end

  attr_reader :app, :ask
  def initialize o={}
    @app = self.class.builder.to_app
    @ask = self.class.builder.to_app(Ask)
    o.each{ |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
  end

  def attributes
    Hash[each_pair.map{ |k, v| [k, send(k)] }]
  end

  def inspect
    "#<struct #{self.class.name} #{attributes.map{ |k, v|
      "#{k}=#{v.inspect}" }.join(', ')}>"
  end

  def lighten! o={}
    attributes.each{ |k, v| case v; when Proc, IO; send("#{k}=", false); end}
    send(:initialize, o)
    self
  end

  def lighten o={}
    dup.lighten!(o)
  end

  def url path, query={}, opts={}
    Middleware.request_uri(
      ask.call(build_env({
        REQUEST_PATH  => path,
        REQUEST_QUERY => query}.merge(opts))))
  end

  # extra options:
  #   auto_decode: Bool # decode with json or not in this API request
  #                     # default: auto_decode in rest-graph instance
  #       timeout: Int  # the timeout for this API request
  #                     # default: timeout in rest-graph instance
  #        secret: Bool # use secret_acccess_token or not
  #                     # default: false
  #         cache: Bool # use cache or not; if it's false, update cache, too
  #                     # default: true
  #    expires_in: Int  # control when would the cache be expired
  #                     # default: nil
  #         async: Bool # use eventmachine for http client or not
  #                     # default: false, but true in aget family
  #       headers: Hash # additional hash you want to pass
  #                     # default: {}
  def get    path, query={}, opts={}, &cb
    request(opts, [:get   , path, query], &cb)
  end

  def delete path, query={}, opts={}, &cb
    request(opts, [:delete, path, query], &cb)
  end

  def post   path, payload={}, query={}, opts={}, &cb
    request(opts, [:post  , path, query, payload], &cb)
  end

  def put    path, payload={}, query={}, opts={}, &cb
    request(opts, [:put   , path, query, payload], &cb)
  end

  # request by eventmachine (em-http)

  def aget    path, query={}, opts={}, &cb
    get(path, query, {:async => true}.merge(opts), &cb)
  end

  def adelete path, query={}, opts={}, &cb
    delete(path, query, {:async => true}.merge(opts), &cb)
  end

  def apost   path, payload={}, query={}, opts={}, &cb
    post(path, payload, query, {:async => true}.merge(opts), &cb)
  end

  def aput    path, payload={}, query={}, opts={}, &cb
    put(path, payload, query, {:async => true}.merge(opts), &cb)
  end

  def multi reqs, opts={}, &cb
    request({:async => true}.merge(opts), *reqs, &cb)
  end

  def request opts, *reqs
    req = reqs.first
    response = app.call(build_env({
      REQUEST_METHOD  => req[0],
      REQUEST_PATH    => req[1],
      REQUEST_QUERY   => req[2] || {},
      REQUEST_PAYLOAD => req[3],
      REQUEST_HEADERS => opts['headers'],
      FAIL            => [],
      LOG             => []}.merge(opts)))[RESPONSE_BODY]

    yield(response) if block_given?
    response
  end
  # ------------------------ instance ---------------------



  protected
  def build_env env={}
    attributes.merge(env).inject({}){ |r, (k, v)|
      r[k.to_s] = v unless v.nil?
      r
    }
  end

  private
  def request_em opts, reqs
    start_time = Time.now
    rs = reqs.map{ |(meth, path, query, payload)|
      r = EM::HttpRequest.new(path).send(meth, :body  => payload,
                                               :head  => build_headers(opts),
                                               :query => query)
      if cached = cache_get(opts, path)
        # TODO: this is hack!!
        r.instance_variable_set('@response', cached)
        r.instance_variable_set('@state'   , :finish)
        r.on_request_complete
        r.succeed(r)
      else
        r.callback{
          cache_for(opts, path, meth, r.response)
          log(env.merge('event' =>
            Event::Requested.new(Time.now - start_time, path)))
        }
        r.error{
          log(env.merge('event' =>
            Event::Failed.new(Time.now - start_time, path)))
        }
      end
      r
    }
    EM::MultiRequest.new(rs){ |m|
      # TODO: how to deal with the failed?
      clients = m.responses[:succeeded]
      results = clients.map{ |client|
        post_request(opts, client.uri, client.response)
      }

      if reqs.size == 1
        yield(results.first)
      else
        log(env.merge('event' => Event::MultiDone.new(Time.now - start_time,
          clients.map(&:uri).join(', '))))
        yield(results)
      end
    }
  end
end
