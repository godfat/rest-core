
require 'thread'

class RestCore::FutureThread < RestCore::Future
  def initialize *args
    super
    self.thread = Thread.current
  end

  def wait
    sleep until status # it might be awaken by some other futures!
  end

  def resume
    return unless thread.alive? && thread.stop?
    thread.wakeup
  end

  protected
  attr_accessor :thread
end
