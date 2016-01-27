
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

$LOAD_PATH.unshift(File.expand_path("#{dir}/promise_pool/lib"))

Gemgem.init(dir) do |s|
  require 'rest-core/version'
  s.name    = 'rest-core'
  s.version = RestCore::VERSION
  %w[promise_pool httpclient mime-types].each do |g|
    s.add_runtime_dependency(g)
  end
end
