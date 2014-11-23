
require 'thread'
require 'timers'

class RestCore::Timer
  @mutex = Mutex.new

  def self.group
    @group ||= @mutex.synchronize{ @group || group_new }
  end

  def self.group_new
    g = Timers::Group.new
    g.every(1){}
    @thread = Thread.new do
      begin
        g.wait
      rescue => e
        warn "timeout exception: #{e}"
      end while g.count > 1
      @group = nil
    end
    g
  end

  attr_accessor :timeout, :error
  def initialize timeout, error, &block
    self.timeout = timeout
    self.error   = error
    self.block   = block
    start
  end

  def on_timeout &block
    self.block = block
  end

  def cancel
    timer.cancel
    self.block = nil
  end

  def start
    return if timeout.nil? || timeout.zero?
    self.timer = self.class.group.after(timeout){ block.call if block }
  end

  protected
  attr_accessor :block, :timer
end
