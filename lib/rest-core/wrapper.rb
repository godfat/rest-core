
require 'rest-core'

module RestCore::Wrapper
  include RestCore
  def self.included mod
    mod.send(:attr_reader, :app, :middles)
  end

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
    middles.map{ |(middle, args, block)|
      if middle.public_method_defined?(:middles)
        # TODO: this is hacky... try to avoid calling new!
        middle.new(Ask.new, *args, &block).members
      else
        middle.members
      end
    }.flatten
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
