
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestGraph do
  after do
    WebMock.reset!
    RR.verify
  end

  should 'be serialized with lighten' do
    engines = begin
                require 'psych'
                YAML::ENGINE.yamler = 'psych' # TODO: probably a bug?
                [Psych, YAML, Marshal]
              rescue LoadError
                [YAML, Marshal]
              end

    # sorry, it is marshal in 1.8 is broken
    if defined?(RUBY_ENGINE) && RUBY_ENGINE  == 'ruby' &&
                                RUBY_VERSION == '1.8.7'
      engines.pop # REE 1.8.7
    else
      engines.pop # MRI 1.8.7
    end

    engines.each{ |engine|
      test = lambda{ |obj| engine.load(engine.dump(obj)) }
        rg = RestGraph.new(:log_handler => lambda{})
      lambda{ test[rg] }.should.raise(TypeError)
      test[rg.lighten].should == rg.lighten
      lambda{ test[rg] }.should.raise(TypeError)
      rg.lighten!
      test[rg.lighten].should == rg
    }
  end

  should 'lighten takes options to change attributes' do
    RestGraph.new.lighten(:timeout => 100    ).timeout.should == 100
    RestGraph.new.lighten(:lang    => 'zh-TW').lang   .should == 'zh-TW'
  end
end
