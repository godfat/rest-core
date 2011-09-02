
require 'rack'

module RestCore::ClientOauth1
  include RestCore

  def authorize_url!
    set_token(Vendor.parse_query(
      post(request_token_path, {}, {}, {:json_decode => false})))

    url(authorize_path, :oauth_token => oauth_token, :format => false)
  end

  def authorize! verifier
    set_token(Vendor.parse_query(
      post(access_token_path, {}, {}, {:verifier => verifier,
                                       :json_decode => false})))
  end

  private
  def set_token query
    self.oauth_token        = query['oauth_token']
    self.oauth_token_secret = query['oauth_token_secret']
  end
end
