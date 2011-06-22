
module RestCore
  REQUEST_METHOD   = 'REQUEST_METHOD'
  REQUEST_PATH     = 'REQUEST_PATH'
  REQUEST_QUERY    = 'REQUEST_QUERY'
  REQUEST_PAYLOAD  = 'REQUEST_PAYLOAD'
  REQUEST_HEADERS  = 'REQUEST_HEADERS'

  RESPONSE_BODY    = 'RESPONSE_BODY'
  RESPONSE_HEADERS = 'RESPONSE_HEADERS'

  FAIL             = 'core.fail'
  LOG              = 'core.log'

  # utilities
  autoload :Builder   , 'rest-core/builder'
  autoload :Client    , 'rest-core/client'
  autoload :Event     , 'rest-core/event'
  autoload :Middleware, 'rest-core/middleware'
  autoload :Wrapper   , 'rest-core/wrapper'

  # middlewares
  autoload :Cache         , 'rest-core/middleware/cache'
  autoload :CommonLogger  , 'rest-core/middleware/common_logger'
  autoload :DefaultHeaders, 'rest-core/middleware/default_headers'
  autoload :DefaultSite   , 'rest-core/middleware/default_site'
  autoload :Defaults      , 'rest-core/middleware/defaults'
  autoload :ErrorDetector , 'rest-core/middleware/error_detector'
  autoload :ErrorHandler  , 'rest-core/middleware/error_handler'
  autoload :JsonDecode    , 'rest-core/middleware/json_decode'
  autoload :Oauth2Query   , 'rest-core/middleware/oauth2_query'
  autoload :Timeout       , 'rest-core/middleware/timeout'

  # apps
  autoload :Ask           , 'rest-core/app/ask'
  autoload :RestClient    , 'rest-core/app/rest-client'
end
