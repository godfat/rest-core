
module RestCore; end
module RestCore::RailsCache
  def []    key       ;  read(key)                ; end
  def []=   key, value; write(key, value)         ; end
  def store key, value,
            options={}; write(key, value, options); end
end
