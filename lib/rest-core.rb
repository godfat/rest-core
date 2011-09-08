
module RestCore
  REQUEST_METHOD   = 'REQUEST_METHOD'
  REQUEST_PATH     = 'REQUEST_PATH'
  REQUEST_QUERY    = 'REQUEST_QUERY'
  REQUEST_PAYLOAD  = 'REQUEST_PAYLOAD'
  REQUEST_HEADERS  = 'REQUEST_HEADERS'

  RESPONSE_BODY    = 'RESPONSE_BODY'
  RESPONSE_STATUS  = 'RESPONSE_STATUS'
  RESPONSE_HEADERS = 'RESPONSE_HEADERS'

  ASK              = 'core.ask'
  FAIL             = 'core.fail'
  LOG              = 'core.log'

  # core utilities
  autoload :Builder       , 'rest-core/builder'
  autoload :Client        , 'rest-core/client'
  autoload :Event         , 'rest-core/event'
  autoload :Middleware    , 'rest-core/middleware'
  autoload :Wrapper       , 'rest-core/wrapper'

  # oauth1 utilities
  autoload :ClientOauth1  , 'rest-core/client_oauth1'

  # misc utilities
  autoload :Hmac          , 'rest-core/util/hmac'
  autoload :Config        , 'rest-core/util/config'
  autoload :Vendor        , 'rest-core/util/vendor'

  # middlewares
  autoload :Bypass        , 'rest-core/middleware/bypass'
  autoload :Cache         , 'rest-core/middleware/cache'
  autoload :CommonLogger  , 'rest-core/middleware/common_logger'
  autoload :DefaultHeaders, 'rest-core/middleware/default_headers'
  autoload :DefaultQuery  , 'rest-core/middleware/default_query'
  autoload :DefaultSite   , 'rest-core/middleware/default_site'
  autoload :Defaults      , 'rest-core/middleware/defaults'
  autoload :ErrorDetector , 'rest-core/middleware/error_detector'
  autoload :ErrorDetectorHttp, 'rest-core/middleware/error_detector_http'
  autoload :ErrorHandler  , 'rest-core/middleware/error_handler'
  autoload :JsonDecode    , 'rest-core/middleware/json_decode'
  autoload :Oauth1Header  , 'rest-core/middleware/oauth1_header'
  autoload :Oauth2Header  , 'rest-core/middleware/oauth2_header'
  autoload :Oauth2Query   , 'rest-core/middleware/oauth2_query'
  autoload :Timeout       , 'rest-core/middleware/timeout'

  # apps
  autoload :Ask           , 'rest-core/app/ask'
  autoload :RestClient    , 'rest-core/app/rest-client'

  # clients
  autoload :Simple        , 'rest-core/client/simple'
  autoload :Github        , 'rest-core/client/github'
  autoload :Twitter       , 'rest-core/client/twitter'
  autoload :Linkedin      , 'rest-core/client/linkedin'
  autoload :Facebook      , 'rest-core/client/facebook'
  autoload :Mixi          , 'rest-core/client/mixi'
end

RC = RestCore unless Object.const_defined?(:RC)
