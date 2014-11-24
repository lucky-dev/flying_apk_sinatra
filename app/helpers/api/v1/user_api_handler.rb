module ApiV1
  module UserApiHandler
    def self.register(params)
      name = params[:name]
      email = params[:email]
      password = params[:password]
    
      user = User.new(name: name, email: email, password: password)
      if user.valid?
        user.save
        return ApiHelper.response(200) do
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
end
