
if respond_to?(:require_relative, true)
  require_relative 'common'
else
  require File.dirname(__FILE__) + '/common'
end

describe RestCore::Oauth1Header do
  should 'have correct base_string' do
    o = RestCore::Oauth1Header.new(RestCore::Ask.new, nil, nil, nil)
    o.base_string(
      {RestCore::REQUEST_METHOD => :post,
       RestCore::REQUEST_PATH   =>
         'https://api.twitter.com/oauth/request_token'},
      {'oauth_callback'     =>
 'http://localhost:3005/the_dance/process_callback?service_provider_id=11'  ,
       'oauth_consumer_key' => 'GDdmIQH6jhtmLUypg82g'                       ,
       'oauth_nonce'        => 'QP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk',
       'oauth_timestamp'    => '1272323042'                                 ,
       'oauth_version'      => '1.0'                                        ,
       'oauth_signature_method' => 'HMAC-SHA1'}).should.

       equal(
       'POST&https%3A%2F%2Fapi.twitter.com%2Foauth%2Frequest_token&' \
       'oauth_callback%3Dhttp%253A%252F%252Flocalhost%253A3005%252F' \
       'the_dance%252Fprocess_callback%253Fservice_provider_id%253D' \
       '11%26oauth_consumer_key%3DGDdmIQH6jhtmLUypg82g%26oauth_nonc' \
       'e%3DQP70eNmVz8jvdPevU3oJD2AfF7R7odC2XJcn4XlZJqk%26oauth_sig' \
       'nature_method%3DHMAC-SHA1%26oauth_timestamp%3D1272323042%26' \
       'oauth_version%3D1.0')
  end
end
