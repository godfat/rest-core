
require 'rest-core'

module RestCore::Client
  include RestCore

  Unserializable = [Proc, Method, IO]

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
          if self.class.respond_to?("default_#{name}")
            self.class.default_#{name}      # old class default style
          elsif app.respond_to?(:#{name})
            app.#{name}({})                 # middleware instance value
          elsif app.respond_to?(:wrapped)
            default_#{name}(app.wrapped) || # wrapper value
            default_#{name}(app.app)        # walk into it
          elsif app.respond_to?(:app)
            default_#{name}(app.app)        # walk into next app
          else
            nil
          end
        end
        private :default_#{name}
      RUBY
    }
    # if RUBY_VERSION < '1.9.2'
    src << <<-RUBY if mod.members.first.kind_of?(String)
      def members
        super.map(&:to_sym)
      end
    RUBY
    # end
    accessor = Module.new
    accessor.module_eval(src.join("\n"), __FILE__, __LINE__)
    mod.const_set('Accessor', accessor)
    mod.send(:include, accessor)
  end

  attr_reader :app, :dry
  def initialize o={}
    @app ||= self.class.builder.to_app
    @dry ||= self.class.builder.to_app(Dry)
    o.each{ |key, value| send("#{key}=", value) if respond_to?("#{key}=") }
  end

  def attributes
    Hash[each_pair.map{ |k, v| [k, send(k)] }]
  end

  def inspect
    fields = attributes.map{ |k, v| "#{k}=#{v.inspect}" }.join(', ')
    "#<struct #{self.class.name}#{if fields.empty? then '' else fields end}>"
  end

  def lighten! o={}
    attributes.each{ |k, v| vv = case v;
                                   when  Hash; lighten_hash(v)
                                   when Array; lighten_array(v)
                                   when *Unserializable; nil
                                   else v
                                 end
                            send("#{k}=", vv)}
    initialize(o)
    @app, @dry = lighten_app(app), lighten_app(dry)
    self
  end

  def lighten o={}
    dup.lighten!(o)
  end

  def url path, query={}, opts={}
    Middleware.request_uri(
      dry.call(build_env({
        REQUEST_PATH  => path,
        REQUEST_QUERY => query,
        DRY           => true}.merge(opts))))
  end

  def get    path, query={}, opts={}, &cb
    request(
      {REQUEST_METHOD  => :get   ,
       REQUEST_PATH    => path   ,
       REQUEST_QUERY   => query  }.merge(opts), &cb)
  end

  def delete path, query={}, opts={}, &cb
    request(
      {REQUEST_METHOD  => :delete,
       REQUEST_PATH    => path   ,
       REQUEST_QUERY   => query  }.merge(opts), &cb)
  end

  def head path, query={}, opts={}, &cb
    request(
      {REQUEST_METHOD  => :head  ,
       REQUEST_PATH    => path   ,
       REQUEST_QUERY   => query  }.merge(opts), &cb)
  end

  def options path, query={}, opts={}, &cb
    request(
      {REQUEST_METHOD  => :options,
       REQUEST_PATH    => path   ,
       REQUEST_QUERY   => query  }.merge(opts), &cb)
  end

  def post   path, payload={}, query={}, opts={}, &cb
    request(
      {REQUEST_METHOD  => :post  ,
       REQUEST_PATH    => path   ,
       REQUEST_QUERY   => query  ,
       REQUEST_PAYLOAD => payload}.merge(opts), &cb)
  end

  def put    path, payload={}, query={}, opts={}, &cb
    request(
      {REQUEST_METHOD  => :put   ,
       REQUEST_PATH    => path   ,
       REQUEST_QUERY   => query  ,
       REQUEST_PAYLOAD => payload}.merge(opts), &cb)
  end

  def patch  path, payload={}, query={}, opts={}, &cb
    request(
      {REQUEST_METHOD  => :patch ,
       REQUEST_PATH    => path   ,
       REQUEST_QUERY   => query  ,
       REQUEST_PAYLOAD => payload}.merge(opts), &cb)
  end

  def request env, app=app
    if block_given?
      request_full(env, app){ |response|
        yield(response[RESPONSE_BODY])
      }
    else
      request_full(env, app)[RESPONSE_BODY]
    end
  end

  def request_full env, app=app
    response = app.call(build_env(
      {REQUEST_METHOD  => :get,
       REQUEST_PATH    => '/' ,
       REQUEST_QUERY   => {}  ,
       REQUEST_PAYLOAD => {}  ,
       REQUEST_HEADERS => {}  ,
       FAIL            => []  ,
       LOG             => []  ,
       ASYNC           => if true#block_given?
                            lambda{ |res| res }
                          else
                            nil
                          end}.merge(env)))

    if false#block_given?
      self
    else
      response
    end
  end

  def build_env env={}
    string_keys(attributes).merge(string_keys(env))
  end
  # ------------------------ instance ---------------------



  private
  def string_keys hash
    hash.inject({}){ |r, (k, v)|
      if v.kind_of?(Hash)
        r[k.to_s] = case k.to_s
                      when REQUEST_QUERY, REQUEST_PAYLOAD, REQUEST_HEADERS
                        string_keys(v)
                      else;         v
                    end
      else
        r[k.to_s] = v
      end
      r
    }
  end

  def lighten_hash hash
    Hash[hash.map{ |(key, value)|
      case value
        when  Hash; lighten_hash(value)
        when Array; lighten_array(value)
        when *Unserializable; [key, nil]
        else [key, value]
      end
    }]
  end

  def lighten_array array
    array.map{ |value|
      case value
        when  Hash; lighten_hash(value)
        when Array; lighten_array(value)
        when *Unserializable; nil
        else value
      end
    }.compact
  end

  def lighten_app app
    members = if app.class.respond_to?(:members)
                app.class.members.map{ |key|
                  case value = app.send(key, {})
                    when  Hash; lighten_hash(value)
                    when Array; lighten_array(value)
                    when *Unserializable; nil
                    else value
                  end
                }
              else
                []
              end

    if app.respond_to?(:app) && app.app
      wrapped = if app.respond_to?(:wrapped) && app.wrapped
                  lighten_app(app.wrapped)
                else
                  nil
                end
      app.class.new(lighten_app(app.app), *members){
        @wrapped = wrapped if wrapped
      }
    else
      app.class.new(*members)
    end
  end
end
