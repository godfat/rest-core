
require 'rest-builder'

module RestCore
  # for backward compatibility
  RestBuilder.constants.each do |const|
    const_set(const, RestBuilder.const_get(const))
  end

  # oauth1 utilities
  autoload :ClientOauth1     , 'rest-core/client_oauth1'

  # misc utilities
  autoload :Hmac             , 'rest-core/util/hmac'
  autoload :Json             , 'rest-core/util/json'
  autoload :ParseLink        , 'rest-core/util/parse_link'
  autoload :ParseQuery       , 'rest-core/util/parse_query'
  autoload :Config           , 'rest-core/util/config'
  autoload :Clash            , 'rest-core/util/clash'
  autoload :Smash            , 'rest-core/util/smash'
  autoload :DalliExtension   , 'rest-core/util/dalli_extension'

  # middlewares
  autoload :AuthBasic        , 'rest-core/middleware/auth_basic'
  autoload :Bypass           , 'rest-core/middleware/bypass'
  autoload :Cache            , 'rest-core/middleware/cache'
  autoload :ClashResponse    , 'rest-core/middleware/clash_response'
  autoload :SmashResponse    , 'rest-core/middleware/smash_response'
  autoload :CommonLogger     , 'rest-core/middleware/common_logger'
  autoload :DefaultHeaders   , 'rest-core/middleware/default_headers'
  autoload :DefaultQuery     , 'rest-core/middleware/default_query'
  autoload :DefaultPayload   , 'rest-core/middleware/default_payload'
  autoload :DefaultSite      , 'rest-core/middleware/default_site'
  autoload :Defaults         , 'rest-core/middleware/defaults'
  autoload :ErrorDetector    , 'rest-core/middleware/error_detector'
  autoload :ErrorDetectorHttp, 'rest-core/middleware/error_detector_http'
  autoload :ErrorHandler     , 'rest-core/middleware/error_handler'
  autoload :FollowRedirect   , 'rest-core/middleware/follow_redirect'
  autoload :JsonRequest      , 'rest-core/middleware/json_request'
  autoload :JsonResponse     , 'rest-core/middleware/json_response'
  autoload :QueryResponse    , 'rest-core/middleware/query_response'
  autoload :Oauth1Header     , 'rest-core/middleware/oauth1_header'
  autoload :Oauth2Header     , 'rest-core/middleware/oauth2_header'
  autoload :Oauth2Query      , 'rest-core/middleware/oauth2_query'
  autoload :Retry            , 'rest-core/middleware/retry'
  autoload :Timeout          , 'rest-core/middleware/timeout'

  # clients
  autoload :Universal        , 'rest-core/client/universal'

  # You might want to call this before launching your application in a
  # threaded environment to avoid thread-safety issue in autoload.
  def self.eagerload const=self, loaded={}
    return if loaded[const.name]
    loaded[const.name] = true
    const.constants(false).each{ |n|
      begin
        c = const.const_get(n)
      rescue LoadError, NameError => e
        warn "RestCore: WARN: #{e} for #{const}\n" \
             "  from #{e.backtrace.grep(/top.+required/).first}"
      end
      eagerload(c, loaded) if c.respond_to?(:constants) && !loaded[n]
    }
  end
end

RC = RestCore unless Object.const_defined?(:RC)
