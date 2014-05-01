
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
    struct = if fields.empty?
               Struct.new(nil)
             else
               Struct.new(*fields.uniq)
             end
    client = Class.new(struct)
    client.const_set('Struct', struct)
    client.send(:include, Client)
    class << client
      attr_reader   :builder
      attr_accessor :pool_size, :pool_idle_time

      def thread_pool
        RestCore::ThreadPool[self]
      end
    end
    client.instance_variable_set(:@builder, self)
    client.instance_variable_set(:@pool_size, 0) # default to no pool
    client.instance_variable_set(:@pool_idle_time, 60) # default to 60 seconds
    client
  end

  def initialize &block
    @engine    = nil
    @middles ||= []
    instance_eval(&block) if block_given?
  end
end
