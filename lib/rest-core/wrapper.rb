
require 'rest-core'

module RestCore::Wrapper
  include RestCore

  module DefaultEngine
    def default_engine
      @default_engine ||= RestCore::Dry
    end
  end

  def self.included mod
    mod.send(:extend, DefaultEngine)
    class << mod
      attr_writer :default_engine
    end
  end

  attr_reader :middles, :wrapped
  attr_writer :default_engine
  def default_engine
    @default_engine ||= self.class.default_engine
  end

  def initialize &block
    @engine    = nil
    @middles ||= []
    instance_eval(&block) if block_given?
    @wrapped ||= to_app
  end

  def use middle, *args, &block
    middles << [middle, args, block]
  end

  def run engine
    @engine = engine
  end

  def members
    middles.map{ |(middle, args, block)|
      if middle.public_method_defined?(:wrapped)
        # TODO: this is hacky... try to avoid calling new!
        middle.members + middle.new(Dry.new, *args, &block).members
      else
        middle.members
      end if middle.respond_to?(:members)
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

  module_function
  def partial_deep_copy obj
    case obj
      when Array; obj.map{ |o| partial_deep_copy(o) }
      when Hash ; obj.inject({}){ |r, (k, v)| r[k] = partial_deep_copy(v); r }
      when Numeric, Symbol, TrueClass, FalseClass, NilClass; obj
      else begin obj.dup; rescue TypeError; obj; end
    end
  end
end
