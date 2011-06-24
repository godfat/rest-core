
module RestCore
  EventStruct = Struct.new(:duration, :message) unless
    RestCore.const_defined?(:EventStruct)

  class Event < EventStruct
    # self.class.name[/(?<=::)\w+$/] if RUBY_VERSION >= '1.9.2'
    def name; self.class.name[/::(\w+)$/, 1]        ; end
    def to_s; "spent #{duration} #{name} #{message}"; end
  end
  class Event::MultiDone    < Event; end
  class Event::Requested    < Event; end
  class Event::CacheHit     < Event; end
  class Event::CacheCleared < Event; end
  class Event::Failed       < Event; end
end
