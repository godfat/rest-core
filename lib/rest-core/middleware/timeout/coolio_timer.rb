
class RestCore::Timeout::CoolioTimer < ::Coolio::TimerWatcher
  attr_accessor :error

  alias_method :cancel, :detach

  def canceled?
    !attached?
  end
end
