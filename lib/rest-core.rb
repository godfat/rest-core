
module RestCore
  REQUEST_METHOD   = 'REQUEST_METHOD'
  REQUEST_PATH     = 'REQUEST_PATH'
  REQUEST_QUERY    = 'REQUEST_QUERY'
  REQUEST_PAYLOAD  = 'REQUEST_PAYLOAD'
  REQUEST_HEADERS  = 'REQUEST_HEADERS'

  RESPONSE_BODY    = 'RESPONSE_BODY'
  RESPONSE_HEADERS = 'RESPONSE_HEADERS'

  autoload :Builder   , 'rest-core/builder'
  autoload :Client    , 'rest-core/client'
  autoload :Event     , 'rest-core/event'
  autoload :Middleware, 'rest-core/middleware'

  # middlewares
  autoload :Cache         , 'rest-core/middleware/cache'
  autoload :CommonLogger  , 'rest-core/middleware/common_logger'
  autoload :DefaultHeaders, 'rest-core/middleware/default_headers'
  autoload :DefaultSite   , 'rest-core/middleware/default_site'
  autoload :ErrorDetector , 'rest-core/middleware/error_detector'
  autoload :ErrorHandler  , 'rest-core/middleware/error_handler'
  autoload :JsonDecode    , 'rest-core/middleware/json_decode'
  autoload :Timeout       , 'rest-core/middleware/timeout'

  # apps
  autoload :RestClient    , 'rest-core/app/rest-client'
end
