
require 'rest-core/test'

describe RestCore::Facebook do
  should 'honor default attributes' do
    RestCore::Facebook.members.reject{ |name|
      name.to_s =~ /method$|handler$|detector$/ }.each{ |name|
        RestCore::Facebook.new.send(name).should ==
        RestCore::Facebook.new.send("default_#{name}")
    }
  end

  should 'use module to override default attributes' do
    klass = RestCore::Facebook.dup
    klass.send(:include, Module.new do
      def default_app_id
        '1829'
      end
    end)

    klass.new.app_id.should == '1829'
  end
end
