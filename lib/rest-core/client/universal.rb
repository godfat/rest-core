
RestCore::Universal = RestCore::Builder.client do
  s = RestCore
  use s::Timeout       , 0

  use s::DefaultSite   , nil
  use s::DefaultHeaders, {}
  use s::DefaultQuery  , {}
  use s::AuthBasic     , nil, nil

  use s::FollowRedirect, 10
  use s::CommonLogger  , method(:puts)
  use s::Cache         ,  {}, 600 do
    use s::ErrorHandler, nil
    use s::ErrorDetectorHttp
    use s::JsonDecode  , false
  end
end
