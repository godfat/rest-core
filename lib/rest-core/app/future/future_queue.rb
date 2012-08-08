
require 'thread'

class RestCore::FutureQueue < RestCore::Future
  def initialize *args
    super
    self.queue = Queue.new
  end

  def wait
    queue.pop unless status
  end

  def resume
    queue << "\0" # signal
  end

  protected
  attr_accessor :queue
end
