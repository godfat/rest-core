
require 'rest-core/middleware'

module RestCore
  class Defaults
    def self.members; [:defaults]; end
    include Middleware

    # the use of singleton_class is making serialization hard!
    # def initialize app, defaults
    #   super
    #   singleton_class.module_eval do
    #     defaults.each{ |(key, value)|
    #       define_method(key) do |env|
    #         if value.respond_to?(:call)
    #           value.call
    #         else
    #           value
    #         end
    #       end
    #     }
    #   end
    # end

    def method_missing msg, *args, &block
      env = args.first
      if env.kind_of?(Hash) && (d = defaults(env)) && d.key?(msg)
        defaults(env)[msg]
      else
        super
      end
    end

    def respond_to_missing? msg, include_private=false
      # since psych would call respond_to? before setting up
      # instance variables when restoring ruby objects, we might
      # be accessing undefined ivars in that case even all ivars are
      # defined in initialize. we can't avoid this because we can't
      # use singleton_class (otherwise we can't serialize this)
      return super unless instance_variable_defined?(:@defaults)
      if (d = defaults({})) && d.key?(msg)
        true
      else
        super
      end
    end
  end
end
