
module RestCore
  Universal = Builder.client do
    use Timeout       , 0

    use DefaultSite   , nil
    use DefaultHeaders, {}
    use DefaultQuery  , {}
    use DefaultPayload, {}
    use AuthBasic     , nil, nil

    use FollowRedirect, 10
    use CommonLogger  , method(:puts)
    use Cache         ,  {}, 600 do
      use ErrorHandler, nil
      use ErrorDetectorHttp
      use JsonResponse, false
    end
  end
end
