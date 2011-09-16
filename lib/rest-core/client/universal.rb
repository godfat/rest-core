
RestCore::Universal = RestCore::Builder.client(:data) do
  s = self.class # this is only for ruby 1.8!
  use s::Timeout       , 0

  use s::DefaultSite   , nil
  use s::DefaultHeaders, {}
  use s::DefaultQuery  , {}

  use s::CommonLogger  , method(:puts)

  use s::Cache         , {}, 3600 do
    use s::ErrorHandler, nil
    use s::ErrorDetectorHttp
    use s::JsonDecode  , false
  end

  use s::Defaults      , :data => lambda{{}}
end
