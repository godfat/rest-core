
# encode and decode will be remove in multi_json 2.0
module MultiJson
  class << self
    alias_method :dump, :encode if not respond_to?(:dump)
    alias_method :load, :decode if not respond_to?(:load)
  end
end
