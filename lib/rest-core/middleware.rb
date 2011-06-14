
require 'rest-core'

require 'cgi'

module RestCore::Middleware
  include RestCore

  def self.included mod
    mod.send(:include, RestCore)
    mod.send(:attr_reader, :app)
    return unless mod.respond_to?(:members)
    src = mod.members.map{ |member| <<-RUBY }
      def #{member} env
        if    env.key?('#{member}')
          env['#{member}']
        else
              @#{member}
        end
      end
    RUBY
    args      = [:app] + mod.members
    args_list = args.join(', ')
    ivar_list = args.map{ |a| "@#{a}" }.join(', ')
    src << <<-RUBY
      def initialize #{args_list}
        #{ivar_list} = #{args_list}
      end
      self
    RUBY
    accessor = Module.new.module_eval(src.join("\n"), __FILE__, __LINE__)
    mod.const_set(:Accessor, accessor)
    mod.send(:include, accessor)
  end

  def call env     ; app.call(env)                               ; end
  def fail env, obj; env.merge(FAIL => (env[FAIL] || []) + [obj]); end
  def log  env, obj; env.merge(LOG  => (env[LOG]  || []) + [obj]); end

  module_function
  def request_uri env
    # compacting the hash
    if (query = env[REQUEST_QUERY].select{ |k, v| v }).empty?
      env[REQUEST_PATH].to_s
    else
      q = if env[REQUEST_PATH] =~ /\?/ then '&' else '?' end
      "#{env[REQUEST_PATH]}#{q}" \
      "#{query.map{ |(k, v)| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')}"
    end
  end
  public :request_uri
end
