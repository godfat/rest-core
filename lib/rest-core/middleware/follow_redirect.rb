
require 'rest-core/middleware'

class RestCore::FollowRedirect
  def self.members; [:max_redirects]; end
  include RestCore::Middleware

  def call env
    e = env.merge('follow_redirect.max_redirects' =>
                    env['follow_redirect.max_redirects'] ||
                    max_redirects(env))

    return app.call(e) if e[DRY]
    if e[ASYNC]
      app.call(e.merge(ASYNC => lambda{ |response|
        e[ASYNC].call(process(response))
      }))
    else
      process(app.call(e))
    end
  end

  def process res
    return res if res['follow_redirect.max_redirects'] <= 0
    return res if ![301,302,303,307].include?(res[RESPONSE_STATUS])
    return res if  [301,302    ,307].include?(res[RESPONSE_STATUS]) &&
                  ![:get, :head    ].include?(res[REQUEST_METHOD])

    location = [res[RESPONSE_HEADERS]['LOCATION']].flatten.first
    meth     = if res[RESPONSE_STATUS] == 303
                 :get
               else
                 res[REQUEST_METHOD]
               end

    call(res.merge(REQUEST_PATH    => location,
                   REQUEST_METHOD  => meth    ,
                   REQUEST_PAYLOAD => nil     ,
                   'follow_redirect.max_redirects' =>
                     res['follow_redirect.max_redirects'] - 1))
  end
end
