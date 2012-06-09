
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
  autoload :ParseQuery    , 'rest-core/util/parse_query'

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
  autoload :JsonDecode    , 'rest-core/middleware/json_decode'
  autoload :Oauth1Header  , 'rest-core/middleware/oauth1_header'
  autoload :Oauth2Header  , 'rest-core/middleware/oauth2_header'
  autoload :Oauth2Query   , 'rest-core/middleware/oauth2_query'
  autoload :Timeout       , 'rest-core/middleware/timeout'

  # apps
  autoload :Auto          , 'rest-core/app/auto'
  autoload :Dry           , 'rest-core/app/dry'
  autoload :RestClient    , 'rest-core/app/rest-client'
  autoload :Coolio        , 'rest-core/app/coolio'
  autoload :CoolioAsync   , 'rest-core/app/coolio-async'
  autoload :CoolioFiber   , 'rest-core/app/coolio-fiber'
  autoload :EmHttpRequest     , 'rest-core/app/em-http-request'
  autoload :EmHttpRequestAsync, 'rest-core/app/em-http-request-async'
  autoload :EmHttpRequestFiber, 'rest-core/app/em-http-request-fiber'
  autoload :EmHttpRequestThunk, 'rest-core/app/em-http-request-thunk'

  # clients
  autoload :Simple        , 'rest-core/client/simple'
  autoload :Universal     , 'rest-core/client/universal'
end

RC = RestCore unless Object.const_defined?(:RC)

begin
  require 'fiber'
rescue LoadError
end
# assume we would always require 'rest-core' in root fiber
RestCore::RootFiber = Fiber.current if Object.const_defined?(:Fiber) &&
                                       Fiber.respond_to?(:current)
