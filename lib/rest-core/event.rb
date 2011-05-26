
module RestCore
  EventStruct = Struct.new(:duration, :url) unless
    RestCore.const_defined?(:EventStruct)

  class Event < EventStruct
    # self.class.name[/(?<=::)\w+$/] if RUBY_VERSION >= '1.9.2'
    def name; self.class.name[/::\w+$/].tr(':', ''); end
    def to_s; "RestCore: spent #{sprintf('%f', duration)} #{name} #{url}";end
  end
  class Event::MultiDone    < Event; end
  class Event::Requested    < Event; end
  class Event::CacheHit     < Event; end
  class Event::CacheCleared < Event; end
  class Event::Failed       < Event; end
end
