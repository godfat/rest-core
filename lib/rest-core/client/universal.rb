
module RestCore
  Universal = Builder.client do
    use Timeout       , 0

    use DefaultSite   , nil
    use DefaultHeaders, {}
    use DefaultQuery  , {}
    use DefaultPayload, {}
    use JsonRequest   , false
    use AuthBasic     , nil, nil
    use CommonLogger  , method(:puts)
    use Cache         ,  {}, 600 # default :expires_in 600 but the default
                                 # cache {} didn't support it
    use ErrorHandler  , nil
    use ErrorDetectorHttp

    use SmashResponse , false
    use ClashResponse , false
    use  JsonResponse , false
    use QueryResponse , false

    use FollowRedirect, 10
  end
end
