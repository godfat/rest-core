
require 'rest-core/client'

class RestCore::Builder
  include RestCore

  def self.client prefix, *attrs, &block
    new(&block).to_client(prefix, *attrs)
  end

  attr_reader :app, :middles
  def initialize &block
    @middles = []
    instance_eval(&block) if block_given?
  end

  def use middle, *args, &block
    middles << [middle, args, block]
  end

  def run app
    @app = app
  end

  def members
    middles.map{ |(middle, args, block)| middle.members }.flatten
  end

  def to_app init=app
    # === foldr m.new app middles
    middles.reverse.inject(init.new){ |app_, (middle, args, block)|
      begin
        middle.new(app_, *partial_deep_copy(args), &block)
      rescue ArgumentError => e
        raise ArgumentError.new("#{middle}: #{e}")
      end
    }
  end

  def partial_deep_copy obj
    case obj
      when Array; obj.map{ |o| partial_deep_copy(o) }
      when Hash ; obj.inject({}){ |r, (k, v)| r[k] = partial_deep_copy(v); r }
      when Numeric, Symbol, TrueClass, FalseClass, NilClass; obj
      else begin obj.dup; rescue TypeError; obj; end
    end
  end

  def to_client prefix, *attrs
    # struct = Struct.new(*members, *attrs) if RUBY_VERSION >= 1.9.2
    struct = Struct.new(*(members + attrs))
    client = Class.new(struct)
    client.send(:include, Client)
    Object.const_set( prefix , client)
    client.const_set('Struct', struct)
    class << client; attr_reader :builder; end
    client.instance_variable_set(:@builder, self)
    client
  end
end
