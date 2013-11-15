class InstagramOAuth2
  def self.members
    [:client_id, :client_secret, :access_token]
  end

  include RestCore::Middleware

  def call env, &block
    access_token = access_token env
    client_id = client_id env

    env =
      if access_token
        env[REQUEST_HEADERS].merge('Authorization' => %{Token token="#{access_token}"})
      elsif client_id
        env[REQUEST_QUERY].merge(client_id: client_id)
      end

    app.call(env, &block)
  end
end
