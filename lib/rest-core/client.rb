
require 'rest-core'

module RestCore::Client
  include RestCore
  def self.included mod
    # honor default attributes
    src = mod.members.map{ |name|
      <<-RUBY
        def #{name}
          if (r = super).nil? && self.class.respond_to?(:default_#{name})
            self.class.default_#{name}
          else
            r
          end
        end
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
    accessor = Module.new.module_eval(src.join("\n"))
    mod.const_set('Accessor', accessor)
    mod.send(:include, accessor)
  end

  attr_reader :app
  def initialize o={}
    (members + [:access_token]).each{ |name|
      send("#{name}=", o[name]) if o.key?(name)
    }
    @app = self.class.builder.to_app
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
    "#{path}#{build_query_string(query, opts)}"
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
    request(opts, [:get   , url(path, query, opts)], &cb)
  end

  def delete path, query={}, opts={}, &cb
    request(opts, [:delete, url(path, query, opts)], &cb)
  end

  def post   path, payload={}, query={}, opts={}, &cb
    request(opts, [:post  , url(path, query, opts), payload],
            &cb)
  end

  def put    path, payload={}, query={}, opts={}, &cb
    request(opts, [:put   , url(path, query, opts), payload],
            &cb)
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
    request({:async => true}.merge(opts),
      *reqs.map{ |(meth, path, query, payload)|
        [meth, url(path, query || {}, opts), payload]
      }, &cb)
  end

  def request opts, *reqs, &cb
    reqs.each{ |(meth, uri, payload)|
      next if meth != :get     # only get result would get cached
      cache_assign(opts, uri, nil)
    } if opts[:cache] == false # remove cache if we don't want it

    if opts[:async]
      request_em(opts, reqs, &cb)
    else
      req = reqs.first
      app.call(build_env.merge(REQUEST_METHOD  => req[0],
                               REQUEST_URI     => req[1],
                               REQUEST_PAYLOAD => req[2],
                               REQUEST_HEADERS => opts[:headers])
                               )[RESPONSE_BODY]
    end
  end
  # ------------------------ instance ---------------------



  protected
  def build_env
    attributes.inject({}){ |r, (k,v)|
      r[k.to_s] = v unless v.nil?
      r
    }
  end

  private
  def request_em opts, reqs
    start_time = Time.now
    rs = reqs.map{ |(meth, uri, payload)|
      r = EM::HttpRequest.new(uri).send(meth, :body => payload,
                                              :head => build_headers(opts))
      if cached = cache_get(opts, uri)
        # TODO: this is hack!!
        r.instance_variable_set('@response', cached)
        r.instance_variable_set('@state'   , :finish)
        r.on_request_complete
        r.succeed(r)
      else
        r.callback{
          cache_for(opts, uri, meth, r.response)
          log(env.merge('event' =>
            Event::Requested.new(Time.now - start_time, uri)))
        }
        r.error{
          log(env.merge('event' =>
            Event::Failed.new(Time.now - start_time, uri)))
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

  def build_query_string query={}, opts={}
    q = query.select{ |k, v| v } # compacting the hash
    return '' if q.empty?
    return '?' + q.map{ |(k, v)| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
  end
end
