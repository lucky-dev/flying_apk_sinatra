module ApiV1
  API_VERSION = 1

  module ApiHandler
    def self.handle(method, *http_header, params)
      if ApiHelper.get_api_version(http_header[0]) == 1
        # Access to resources without an access token
        if method == :register
          UserApiHandler.register(params)
        elsif method == :login
          UserApiHandler.login(params)
        else
          # Access to resources with an access token
          user = User.where(access_token: http_header[1]).first
          if user
            # Access token is OK
            if method == :create_android_app
              AndroidAppApiHandler.create(user, params)
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
  
  module UserApiHandler
    def self.register(params)
      name = params[:name]
      email = params[:email]
      password = params[:password]
      
      user = User.new(name: name, email: email, password: password)
      if user.valid?
        return ApiHelper.response(200) do
          user.save
          { api_version: API_VERSION, response: { access_token: user.access_token } }
        end
      else
        return ApiHelper.response(500) do
          { api_version: API_VERSION, response: { errors: user.errors.full_messages.uniq } }
        end
      end
    end
    
    def self.login(params)
      email = params[:email]
      password = params[:password]

      user = User.where(email: email).first
      if user
        if UserHelper.equal_passwords?(password, user.encoded_password)
          return ApiHelper.response(200) do
            user.access_token = UserHelper.generate_access_token(user.name, user.email)
            user.save
            { api_version: API_VERSION, response: { access_token: user.access_token } }
          end
        else
          return ApiHelper.response(500) do
            { api_version: API_VERSION, response: { errors: [ "password is wrong" ] } }
          end
        end
      else
        return ApiHelper.response(500) do
          { api_version: API_VERSION, response: { errors: [ "email is not found" ] } }
        end
      end
    end
  end
  
  module AndroidAppApiHandler
    def self.create(user, params)
      name = params[:name]
      description = params[:description]

      android_app = AndroidApp.new(name: name, description: description)
      if android_app.valid?
        android_app.save
        
        permission = PermissionApp.create(user_id: user.id, android_app_id: android_app.id, permission: 'READ_WRITE')
        permission.save
        
        return ApiHelper.response(200) do
          { api_version: API_VERSION, response: { android_app: { id: android_app.id, name: android_app.name, description: android_app.description } } }
        end
      else
        return ApiHelper.response(500) do
          { api_version: API_VERSION, response: { errors: android_app.errors.full_messages.uniq } }
        end
      end
    end
  end
end
