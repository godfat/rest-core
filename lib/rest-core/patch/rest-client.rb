
module RestClient
  module AbstractResponse
    # begin patch
    # https://github.com/archiloque/rest-client/pull/103
    remove_method :to_i if method_defined?(:to_i)
    # end patch

    # Follow a redirection
    def follow_redirection request = nil, result = nil, & block
      url = headers[:location]
      if url !~ /^http/
        url = URI.parse(args[:url]).merge(url).to_s
      end
      args[:url] = url
      if request
        if request.max_redirects == 0
          # begin patch
          # https://github.com/archiloque/rest-client/pull/118
          raise MaxRedirectsReached.new(self, code)
          # end patch
        end
        args[:password] = request.password
        args[:user] = request.user
        args[:headers] = request.headers
        args[:max_redirects] = request.max_redirects - 1
        # pass any cookie set in the result
        if result && result['set-cookie']
          args[:headers][:cookies] = (args[:headers][:cookies] || {}).merge(parse_cookie(result['set-cookie']))
        end
      end
      Request.execute args, &block
    end
  end
end
