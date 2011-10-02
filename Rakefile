# encoding: utf-8

require "#{dir = File.dirname(__FILE__)}/task/gemgem"
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

module Gemgem
  module_function
  def test_rails *rails
    rails.each{ |framework|
      opts = Rake.application.options
      args = (opts.singleton_methods - [:rakelib, 'rakelib']).map{ |arg|
               if arg.to_s !~ /=$/ && opts.send(arg)
                 "--#{arg}"
               else
                 ''
               end
             }.join(' ')
      Rake.sh "cd example/#{framework}; #{Gem.ruby} -S rake test #{args}"
    }
  end
end

desc 'Run example tests'
task 'test:example' do
  Gemgem.test_rails('rails3', 'rails2')
end

desc 'Run all tests'
task 'test:all' => ['test', 'test:example']

desc 'Run different json test'
task 'test:json' do
  %w[yajl json].each{ |json|
    Rake.sh "#{Gem.ruby} -S rake -r #{json} test"
  }
end

task 'test:travis' do
  case ENV['RESTCORE']
  when 'rails3'; Gemgem.test_rails('rails3')
  when 'rails2'; Gemgem.test_rails('rails2')
  else         ; Rake::Task['test'].invoke
  end
end
