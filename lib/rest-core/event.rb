
module RestCore
  class Event < Struct.new(:duration, :message)
    def name; self.class.name[/(?<=::)\w+$/]; end
    def to_s
      if duration
        "spent #{duration} #{name} #{message}"
      else
        "#{name} #{message}"
      end
    end
  end

  Event::MultiDone    = Class.new(Event)
  Event::Requested    = Class.new(Event)
  Event::CacheHit     = Class.new(Event)
  Event::CacheCleared = Class.new(Event)
  Event::Failed       = Class.new(Event)
  Event::WithHeader   = Class.new(Event)
  Event::Retrying     = Class.new(Event)
end
