
require 'rest-core'

require 'cgi'

module RestCore::Middleware
  include RestCore

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

  def try env
    if app.respond_to?(:try)
      app.try(env)
    else
      env
    end
  end

  module_function
  def request_uri env
    e = try(env)
    # compacting the hash
    if (query = e[REQUEST_QUERY].select{ |k, v| v }).empty?
      e[REQUEST_PATH].to_s
    else
      "#{e[REQUEST_PATH ]}?" \
      "#{query.map{ |(k, v)| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')}"
    end
  end
  public :request_uri
end
