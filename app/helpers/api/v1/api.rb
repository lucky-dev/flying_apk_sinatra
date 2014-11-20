module ApiV1
  API_VERSION = 1

  class ApiHandler
    def self.handle(method, http_accept, params)
      if ApiHelper.get_api_version(http_accept) == 1
        if method == :register
          register(http_accept, params)
        elsif method == :login
          login(http_accept, params)
        end
      else
        return ApiHelper.response(406) do
          { api_version: API_VERSION, response: { errors: [ "bad header" ] } }
        end
      end
    end

    def self.register(http_accept, params)
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
    
    def self.login(http_accept, params)
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
end
