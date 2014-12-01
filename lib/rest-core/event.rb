
module RestCore
  EventStruct = Struct.new(:duration, :message) unless
    RestCore.const_defined?(:EventStruct)

  class Event < EventStruct
    def name; self.class.name[/(?<=::)\w+$/]; end
    def to_s
      if duration
        "spent #{duration} #{name} #{message}"
      else
        "#{name} #{message}"
      end
    end
  end
  class Event::MultiDone    < Event; end
  class Event::Requested    < Event; end
  class Event::CacheHit     < Event; end
  class Event::CacheCleared < Event; end
  class Event::Failed       < Event; end
  class Event::WithHeader   < Event; end
end
