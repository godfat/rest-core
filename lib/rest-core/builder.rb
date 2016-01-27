
require 'thread'
require 'weakref'
require 'rest-core/client'

module RestCore; end
class RestCore::Builder
  include RestCore

  singleton_class.module_eval do
    attr_writer :default_engine
    def default_engine
      @default_engine ||= RestCore::HttpClient
    end

    def client *attrs, &block
      new(&block).to_client(*attrs)
    end
  end

  def initialize &block
    @engine    = nil
    @middles ||= []
    instance_eval(&block) if block_given?
  end

  attr_reader :middles
  attr_writer :default_engine
  def default_engine
    @default_engine ||= self.class.default_engine
  end

  def use middle, *args, &block
    middles << [middle, args, block]
  end

  def run engine
    @engine = engine
  end

  def members
    middles.map{ |(middle, _, _)|
      middle.members if middle.respond_to?(:members)
    }.flatten.compact
  end

  def to_app engine=@engine || default_engine
    # === foldr m.new app middles
    middles.reverse.inject(engine.new){ |app, (middle, args, block)|
      begin
        middle.new(app, *partial_deep_copy(args), &block)
      rescue ArgumentError => e
        raise ArgumentError.new("#{middle}: #{e}")
      end
    }
  end

  def to_client *attrs
    fields = (members + attrs + [:config_engine]).uniq
    struct = build_struct(fields)
    client = Class.new(struct)
    client.const_set('Struct', struct)
    class_methods = build_class_methods
    client.const_set('ClassMethods', class_methods)
    client.singleton_class.send(:include, class_methods)
    client.send(:include, Client)
    client.builder            = self
    client.pool_size          =  0 # default to no pool
    client.pool_idle_time     = 60 # default to 60 seconds
    client.event_source_class = EventSource
    client.promises           = []
    client.mutex              = Mutex.new
    client
  end

  private
  def partial_deep_copy obj
    case obj
      when Array; obj.map{ |o| partial_deep_copy(o) }
      when Hash ; obj.inject({}){ |r, (k, v)| r[k] = partial_deep_copy(v); r }
      else      ; obj
    end
  end

  def build_struct fields
    if fields.empty?
      Struct.new(nil)
    else
      Struct.new(*fields.uniq)
    end
  end

  def build_class_methods
    Module.new do
      attr_accessor :builder, :event_source_class, :promises, :mutex
      attr_reader :pool_size, :pool_idle_time

      def inherited sub
        sub.builder            = builder
        sub.pool_size          = pool_size
        sub.pool_idle_time     = pool_idle_time
        sub.event_source_class = event_source_class
        sub.promises           = []
        sub.mutex              = Mutex.new
      end

      def pool_size= size
        @pool_size = size
        thread_pool.max_size = size
      end

      def pool_idle_time= time
        @pool_idle_time = time
        thread_pool.idle_time = time
      end

      def thread_pool
        @thread_pool ||=
          PromisePool::ThreadPool.new(pool_size, pool_idle_time)
      end

      def defer
        raise ArgumentError.new('no block given') unless block_given?
        promise = PromisePool::Promise.new(thread_pool)
        give_promise(WeakRef.new(promise))
        promise.defer{ yield }.future
      end

      def give_promise weak_promise, ps=promises, m=mutex
        m.synchronize do
          ps << weak_promise
          ps.keep_if(&:weakref_alive?)
        end
      end

      # Shutdown the thread pool for this client and wait for all requests
      def shutdown
        thread_pool.shutdown
        wait
      end

      # Wait for all the requests to be done for this client
      def wait ps=promises, m=mutex
        return self if ps.empty?
        current_promises = nil
        m.synchronize do
          current_promises = ps.dup
          ps.clear
        end
        current_promises.each do |p|
          next unless p.weakref_alive?
          begin
            p.wait
          rescue WeakRef::RefError # it's gc'ed after we think it's alive
          end
        end
        wait(ps, m)
      end
    end
  end
end
