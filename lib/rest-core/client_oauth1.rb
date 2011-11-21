
require 'rest-core'

module RestCore::ClientOauth1
  include RestCore

  def authorize_url!
    set_token(ParseQuery.parse_query(
      post(request_token_path, {}, {}, {:json_decode => false})))

    url(authorize_path, :oauth_token => oauth_token, :format => false)
  end

  def authorize! verifier
    set_token(ParseQuery.parse_query(
      post(access_token_path, {}, {}, {:verifier => verifier,
                                       :json_decode => false})))
  end

  def data
    super || {}
  end

  def data_json
    JsonDecode.json_encode(data.merge('sig' => calculate_sig))
  end

  def data_json= json
    self.data = check_sig_and_return_data(JsonDecode.json_decode(json))
  rescue JsonDecode.const_get(:ParseError)
    self.data = nil
  end

  def oauth_token
    data['oauth_token'] if data.kind_of?(Hash)
  end
  def oauth_token= token
    data['oauth_token'] = token if data.kind_of?(Hash)
  end
  def oauth_token_secret
    data['oauth_token_secret'] if data.kind_of?(Hash)
  end
  def oauth_token_secret= secret
    data['oauth_token_secret'] = secret if data.kind_of?(Hash)
  end

  private
  def set_token query
    self.oauth_token        = query['oauth_token']
    self.oauth_token_secret = query['oauth_token_secret']
  end

  def check_sig_and_return_data hash
    hash if consumer_secret && hash.kind_of?(Hash) &&
            calculate_sig(hash) == hash['sig']
  end

  def calculate_sig hash=data
    base = hash.reject{ |(k, _)| k == 'sig' }.sort.map{ |(k, v)|
      "#{escape(k)}=#{escape(v)}"
    }.join('&')
    Digest::MD5.hexdigest("#{escape(consumer_secret)}&#{base}")
  end

  def escape string
    CGI.escape(string).gsub('+', '%20')
  end
end
