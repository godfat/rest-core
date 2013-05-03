
module RestCore
  REQUEST_METHOD   = 'REQUEST_METHOD'
  REQUEST_PATH     = 'REQUEST_PATH'
  REQUEST_QUERY    = 'REQUEST_QUERY'
  REQUEST_PAYLOAD  = 'REQUEST_PAYLOAD'
  REQUEST_HEADERS  = 'REQUEST_HEADERS'

  RESPONSE_BODY    = 'RESPONSE_BODY'
  RESPONSE_STATUS  = 'RESPONSE_STATUS'
  RESPONSE_HEADERS = 'RESPONSE_HEADERS'

  DRY              = 'core.dry'
  FAIL             = 'core.fail'
  LOG              = 'core.log'

  ASYNC            = 'async.callback'
  TIMER            = 'async.timer'
  FUTURE           = 'async.future'

  RootFiber        = Fiber.respond_to?(:current) && Fiber.current

  # core utilities
  autoload :Builder       , 'rest-core/builder'
  autoload :Client        , 'rest-core/client'
  autoload :Error         , 'rest-core/error'
  autoload :Event         , 'rest-core/event'
  autoload :Middleware    , 'rest-core/middleware'
  autoload :Wrapper       , 'rest-core/wrapper'

  # oauth1 utilities
  autoload :ClientOauth1  , 'rest-core/client_oauth1'

  # misc utilities
  autoload :Hmac          , 'rest-core/util/hmac'
  autoload :Json          , 'rest-core/util/json'
  autoload :ParseQuery    , 'rest-core/util/parse_query'
  autoload :Payload       , 'rest-core/util/payload'

  # middlewares
  autoload :AuthBasic     , 'rest-core/middleware/auth_basic'
  autoload :Bypass        , 'rest-core/middleware/bypass'
  autoload :Cache         , 'rest-core/middleware/cache'
  autoload :CommonLogger  , 'rest-core/middleware/common_logger'
  autoload :DefaultHeaders, 'rest-core/middleware/default_headers'
  autoload :DefaultQuery  , 'rest-core/middleware/default_query'
  autoload :DefaultPayload, 'rest-core/middleware/default_payload'
  autoload :DefaultSite   , 'rest-core/middleware/default_site'
  autoload :Defaults      , 'rest-core/middleware/defaults'
  autoload :ErrorDetector , 'rest-core/middleware/error_detector'
  autoload :ErrorDetectorHttp, 'rest-core/middleware/error_detector_http'
  autoload :ErrorHandler  , 'rest-core/middleware/error_handler'
  autoload :FollowRedirect, 'rest-core/middleware/follow_redirect'
  autoload :JsonRequest   , 'rest-core/middleware/json_request'
  autoload :JsonResponse  , 'rest-core/middleware/json_response'
  autoload :Oauth1Header  , 'rest-core/middleware/oauth1_header'
  autoload :Oauth2Header  , 'rest-core/middleware/oauth2_header'
  autoload :Oauth2Query   , 'rest-core/middleware/oauth2_query'
  autoload :Timeout       , 'rest-core/middleware/timeout'

  # engines
  autoload :Auto          , 'rest-core/engine/auto'
  autoload :Dry           , 'rest-core/engine/dry'
  autoload :RestClient    , 'rest-core/engine/rest-client'
  autoload :EmHttpRequest , 'rest-core/engine/em-http-request'

  # clients
  autoload :Simple        , 'rest-core/client/simple'
  autoload :Universal     , 'rest-core/client/universal'

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
