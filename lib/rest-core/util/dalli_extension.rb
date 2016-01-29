
module RestCore
  module DalliExtension
    def [] *args
      get(*args)
    end

    def []= *args
      set(*args)
    end

    def store key, value, expires_in: nil
      set(key, value, expires_in)
    end
  end
end
