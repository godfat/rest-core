
require 'openssl'

module RestCore; end
module RestCore::Hmac
  module_function
  # Fallback to ruby-hmac gem in case system openssl
  # lib doesn't support SHA256 (OSX 10.5)
  def sha256 key, data
    OpenSSL::HMAC.digest('sha256', key, data)
  end

  def sha1 key, data
    OpenSSL::HMAC.digest('sha1', key, data)
  end
end
