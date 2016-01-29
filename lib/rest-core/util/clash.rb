
module RestCore
  class Clash
    Empty = Hash.new(&(l = lambda{|_,_|Hash.new(&l).freeze})).freeze

    attr_accessor :data
    def initialize data
      self.data = data
    end

    def [] k
      if data.key?(k)
        convert(data[k])
      else
        Empty
      end
    end

    def == rhs
      if rhs.kind_of?(Clash)
        data == rhs.data
      else
        data == rhs
      end
    end

    private
    def convert value
      case value
      when Hash
        Clash.new(value)
      when Array
        value.map{ |ele| convert(ele) }
      else
        value
      end
    end

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
end
