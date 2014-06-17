
module RestCore; end
class RestCore::Smash
  attr_accessor :data
  def initialize data
    self.data = data
  end

  def [] *keys
    keys.inject(data) do |r, k|
      if r.respond_to?(:key) && r.key?(k)
        r[k]
      elsif r.respond_to?(:[])
        r[k]
      else
        return nil # stop here
      end
    end
  end

  def == rhs
    if rhs.kind_of?(RestCore::Smash)
      data == rhs.data
    else
      data == rhs
    end
  end

  private
  def respond_to_missing? msg, include_private=false
    data.respond_to?(msg, include_private)
  end

  def method_missing msg, *args, &block
    if data.respond_to?(msg)
      data.public_send(msg, *args, &block)
    else
      super
    end
  end
end
