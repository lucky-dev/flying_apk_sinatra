module ApiV1
  module UserApiHandler
    def self.register(params)
      name = params[:name]
      email = params[:email]
      password = params[:password]
    
      user = User.new(name: name, email: email, password: password)
      if user.valid?
        user.save
        access_token = UserHelper.generate_access_token(user.name, user.email)
        user.add_access_token(access_token: access_token)
        return ApiHelper.response(200) do
          { api_version: API_VERSION, response: { access_token: access_token } }
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
            user.save
            access_token = UserHelper.generate_access_token(user.name, user.email)
            user.add_access_token(access_token: access_token)
            { api_version: API_VERSION, response: { access_token: access_token } }
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
    
    def self.logout(user, access_token)
      user_id = user.id
      user.access_tokens_dataset.where(access_token: access_token).delete
      return ApiHelper.response(200) do
        { api_version: API_VERSION, response: { user_id: user_id } }
      end
    end
  end
end
