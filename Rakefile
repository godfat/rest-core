# encoding: utf-8

begin
  require "#{dir = File.dirname(__FILE__)}/task/gemgem"
rescue LoadError
  sh "git submodule update --init"
  exec Gem.ruby, "-S", "rake", *ARGV
end

Gemgem.dir = dir
($LOAD_PATH << File.expand_path("#{Gemgem.dir}/lib" )).uniq!

desc 'Generate gemspec'
task 'gem:spec' do
  Gemgem.spec = Gemgem.create do |s|
    require 'rest-core/version'
    s.name     = 'rest-core'
    s.version  = RestCore::VERSION
    s.homepage = 'https://github.com/cardinalblue/rest-core'

    %w[rest-client].each{ |g| s.add_runtime_dependency(g) }

    s.authors  = ['Cardinal Blue', 'Lin Jen-Shin (godfat)']
    s.email    = ['dev (XD) cardinalblue.com']
  end

  Gemgem.write
end
