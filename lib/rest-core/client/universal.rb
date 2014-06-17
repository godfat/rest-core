
module RestCore
  Universal = Builder.client do
    use Timeout       , 0

    use DefaultSite   , nil
    use DefaultHeaders, {}
    use DefaultQuery  , {}
    use DefaultPayload, {}
    use JsonRequest   , false
    use AuthBasic     , nil, nil

    use FollowRedirect, 10
    use CommonLogger  , method(:puts)
    use Cache         ,  {}, 600 do
      use ErrorHandler, nil
      use ErrorDetectorHttp
      use SmashResponse, false
      use ClashResponse, false
      use JsonResponse , false
      use QueryResponse, false
    end
  end
end
