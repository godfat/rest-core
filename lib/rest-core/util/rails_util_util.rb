
module RestCore; end
module RestCore::RailsUtilUtil
  module Cache
    def []    key       ;  read(key)                ; end
    def []=   key, value; write(key, value)         ; end
    def store key, value,
              options={}; write(key, value, options); end
  end

  module_function
  def extract_options members, options, method
    # Hash[] is for ruby 1.8.7
    # map(&:to_sym) is for ruby 1.8.7
    Hash[options.send(method){ |(k, v)| members.map(&:to_sym).member?(k) }]
  end
end

ActiveSupport::Cache::Store.send(:include, RestCore::RailsUtilUtil::Cache)
