
require 'fiber'
require 'em-http-request'
require 'rest-core'

require 'rr'
require 'webmock'
require 'bacon'

# for testing lighten (serialization)
require 'yaml'

include RR::Adapters::RRMethods
include WebMock::API
WebMock.disable_net_connect!(:allow_localhost => true)
Bacon.summary_on_exit

module Kernel
  def eq? rhs
    self == rhs
  end

  def lt? rhs
    self < rhs
  end

  def with_img
    f = Tempfile.new(['img', '.jpg'])
    n = File.basename(f.path)
    f.write('a'*10)
    f.rewind
    yield(f, n)
  ensure
    f.close!
  end
end

# https://github.com/bblimke/webmock/pull/280
class ::EventMachine::WebMockHttpClient
  def build_request_signature
    headers, body = @req.headers, @req.body

    @conn.middleware.select {|m| m.respond_to?(:request) }.each do |m|
      headers, body = m.request(self, headers, body)
    end

    method = @req.method
    uri = @req.uri.clone
    auth = @req.headers[:'proxy-authorization']
    query = @req.query

    if auth
      userinfo = auth.join(':')
      userinfo = WebMock::Util::URI.encode_unsafe_chars_in_userinfo(userinfo)
      if @req
        @req.proxy.reject! {|k,v| t.to_s == 'authorization' }
      else
        options.reject! {|k,v| k.to_s == 'authorization' } #we added it to url userinfo
      end
      uri.userinfo = userinfo
    end

    uri.query = encode_query(@req.uri, query).slice(/\?(.*)/, 1)

    body = form_encode_body(body) if body.is_a?(Hash)

    WebMock::RequestSignature.new(
      method.downcase.to_sym,
      uri.to_s,
      :body => body || (@req.file && File.read(@req.file)),
      :headers => headers
    )
  end
end
