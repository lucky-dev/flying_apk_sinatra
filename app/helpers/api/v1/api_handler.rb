module ApiV1
  API_VERSION = 1

  module ApiHandler
    def self.handle(method, *http_header, params)
      if ApiHelper.get_api_version(http_header[0]) == API_VERSION
        # Access to resources without an access token
        if method == :register
          UserApiHandler.register(params)
        elsif method == :login
          UserApiHandler.login(params)
        else
          # Access to resources with an access token
          user = User.where(id: AccessToken.select(:user_id).where(access_token: http_header[1])).first
          if user
            # Access token is OK
            if method == :logout
              UserApiHandler.logout(user, http_header[1])
            elsif method == :create_android_app
              AndroidAppApiHandler.create(user, params)
            elsif method == :get_android_apps
              AndroidAppApiHandler.get_android_apps(user)
            elsif method == :update_android_app
              AndroidAppApiHandler.update_android_app(user, params)
            elsif method == :delete_android_app
              AndroidAppApiHandler.delete_android_app(user, params)
            elsif method == :create_build
              BuildApiHandler.create_build(user, params)
            elsif method == :get_builds
              BuildApiHandler.get_builds(user, params)
            elsif method == :update_build
              BuildApiHandler.update_build(user, params)
            elsif method == :delete_build
              BuildApiHandler.delete_build(user, params)
            elsif method == :add_user_to_app
              AndroidAppApiHandler.add_user_to_app(user, params)
            else method == :remove_user_from_app
              AndroidAppApiHandler.remove_user_from_app(user, params)
            end
          else
            # Access token is BAD
            return ApiHelper.response(401) do
              { api_version: API_VERSION, response: { errors: [ "user is unauthorized" ] } }
            end
          end
        end
      else
        return ApiHelper.response(406) do
          { api_version: API_VERSION, response: { errors: [ "bad header" ] } }
        end
      end
    end
  end
end
