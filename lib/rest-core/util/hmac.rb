
require 'openssl'

module RestCore; end
module RestCore::Hmac
  module_function
  def sha256 key, data
    OpenSSL::HMAC.digest('sha256', key, data)
  end

  def sha1 key, data
    OpenSSL::HMAC.digest('sha1', key, data)
  end
end
