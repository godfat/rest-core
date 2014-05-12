
require 'thread'
require 'rest-core/client'
require 'rest-core/wrapper'

class RestCore::Builder
  include RestCore
  include Wrapper

  def self.default_engine
    @default_engine ||= RestCore::HttpClient
  end

  def self.client *attrs, &block
    new(&block).to_client(*attrs)
  end

  def to_client *attrs
    fields = members + attrs
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

  def build_struct fields
    if fields.empty?
      Struct.new(nil)
    else
      Struct.new(*fields.uniq)
    end
  end

  def build_class_methods
    Module.new do
      attr_accessor :builder, :pool_size, :pool_idle_time,
                    :event_source_class, :promises, :mutex
      def thread_pool; RestCore::ThreadPool[self]; end

      def give_promise weak_promise
        mutex.synchronize{ promises << weak_promise }
      end

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

  def initialize &block
    @engine    = nil
    @middles ||= []
    instance_eval(&block) if block_given?
  end
end
