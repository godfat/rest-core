
module RestCore
  class FollowRedirect
    def self.members; [:max_redirects]; end
    include Middleware

    def call env, &k
      if env[DRY]
        app.call(env, &k)
      else
        app.call(env){ |res| process(res, k) }
      end
    end

    def process res, k
      return k.call(res) if max_redirects(res) <= 0
      status = res[RESPONSE_STATUS]
      return k.call(res) if ![301,302,303,307].include?(status)
      return k.call(res) if  [301,302    ,307].include?(status) &&
                            ![:get, :head    ].include?(res[REQUEST_METHOD])

      location = [res[RESPONSE_HEADERS]['LOCATION']].flatten.first
      meth     = if status == 303
                   :get
                 else
                   res[REQUEST_METHOD]
                 end

      give_promise(call(res.merge(
        REQUEST_METHOD => meth    ,
        REQUEST_PATH   => location,
        REQUEST_QUERY  => {}      ,
        'max_redirects' => max_redirects(res) - 1), &k))
    end
  end
end
