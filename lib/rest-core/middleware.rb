
require 'rest-core'

module RestCore::Middleware
  def self.included mod
    mod.send(:include, RestCore)
    mod.send(:attr_reader, :app)
    return unless mod.respond_to?(:members)
    accessors = mod.members.map{ |member| <<-RUBY }.join("\n")
      def #{member} env
        if env.key?('#{member}')
          env['#{member}']
        else
          @#{member}
        end
      end
    RUBY
    args      = [:app] + mod.members
    args_list = args.join(', ')
    ivar_list = args.map{ |a| "@#{a}" }.join(', ')
    initialize = <<-RUBY
      def initialize #{args_list}
        #{ivar_list} = #{args_list}
      end
    RUBY
    mod.module_eval("#{accessors}\n#{initialize}")
  end
  def call env; app.call(env)                          ; end
  def fail env; app.fail(env) if app.respond_to?(:fail); end
  def log  env; app. log(env) if app.respond_to?(:log ); end
end
