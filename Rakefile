
begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh 'git submodule update --init --recursive'
  exec Gem.ruby, '-S', $PROGRAM_NAME, *ARGV
end

$LOAD_PATH.unshift(File.expand_path("#{dir}/rest-builder/lib"))
$LOAD_PATH.unshift(File.expand_path("#{dir}/rest-builder/promise_pool/lib"))

Gemgem.init(dir) do |s|
  require 'rest-core/version'
  s.name    = 'rest-core'
  s.version = RestCore::VERSION
  %w[rest-builder].each do |g|
    s.add_runtime_dependency(g)
  end

  # exclude rest-builder
  s.files.reject!{ |f| f.start_with?('rest-builder/') }
end

desc 'Run console'
task 'console' do
  ARGV.shift
  load `which rib`.chomp
end
