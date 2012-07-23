
require 'rest-core'

module RestCore::Wrapper
  include RestCore

  module DefaultApp
    def default_app
      @default_app ||= RestCore::Dry
    end
  end

  def self.included mod
    mod.send(:extend, DefaultApp)
    class << mod
      attr_writer :default_app
    end
  end

  attr_reader :init, :middles, :wrapped
  attr_writer :default_app
  def default_app
    @default_app ||= self.class.default_app
  end

  def initialize &block
    @middles ||= []
    instance_eval(&block) if block_given?
    @wrapped ||= to_app
    @init      = nil
  end

  def use middle, *args, &block
    middles << [middle, args, block]
  end

  def run app
    @init = app
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

  def to_app app=init || default_app
    # === foldr m.new app middles
    middles.reverse.inject(app.new){ |app_, (middle, args, block)|
      begin
        middle.new(app_, *partial_deep_copy(args), &block)
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
