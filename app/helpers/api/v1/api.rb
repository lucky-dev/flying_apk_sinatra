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
            elsif method == :get_android_apps
              AndroidAppApiHandler.get_android_apps(user)
            elsif method == :update_android_app
              AndroidAppApiHandler.update_android_app(user, params)
            elsif method == :delete_android_app
              AndroidAppApiHandler.delete_android_app(user, params)
            elsif method == :create_build
              BuildApiHandler.create_build(user, params)
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

    def self.get_android_apps(user)
      all_apps = AndroidApp.where(id: user.permission_apps_dataset.select(:android_app_id)).order(:id).all
      
      apps = []
      all_apps.each do |app|
        apps << { id: app.id, name: app.name, description: app.description }
      end
      
      return ApiHelper.response(200) do
        { api_version: API_VERSION, response: { apps: apps } }
      end
    end
    
    def self.update_android_app(user, params)
      id = params[:id]
      name = params[:name]
      description = params[:description]
      
      permission_for_app = user.permission_apps_dataset.where(android_app_id: id, permission: 'READ_WRITE').first
      if permission_for_app
        android_app = permission_for_app.android_app

        android_app.name = name || android_app.name
        android_app.description = description || android_app.description
        
        if android_app.valid?
          return ApiHelper.response(200) do
            { api_version: API_VERSION, response: { app: { name: android_app.name, description: android_app.description } } }
          end
        else
          return ApiHelper.response(500) do
            { api_version: API_VERSION, response: { errors: android_app.errors.full_messages.uniq } }
          end
        end
      else
        return ApiHelper.response(403) do
          { api_version: API_VERSION, response: { errors: [ "you don't have permission to this resource" ] } }
        end
      end
    end
    
    def self.delete_android_app(user, params)
      id = params[:id]
      name = params[:name]
      description = params[:description]
      
      permission_for_app = user.permission_apps_dataset.where(android_app_id: id, permission: 'READ_WRITE').first
      if permission_for_app
        android_app = permission_for_app.android_app
        
        permission_for_app.delete
        android_app.delete
        
        return ApiHelper.response(200) do
          { api_version: API_VERSION, response: { app: { id: android_app.id } } }
        end
      else
        return ApiHelper.response(403) do
          { api_version: API_VERSION, response: { errors: [ "you don't have permission to this resource" ] } }
        end
      end
    end
  end
  
  module BuildApiHandler    
    def self.create_build(user, params)
      version = params[:version]
      fixes = params[:fixes]
      app_id = params[:app_id]
      file = params[:file]
      
      permission_for_app = user.permission_apps_dataset.where(android_app_id: app_id, permission: 'READ_WRITE').first
      if permission_for_app
        build = Build.new(version: version, fixes: fixes)
        
        if build.valid?
          if file
            filename = file[:filename]
            tempfile = file[:tempfile]
            
            if BuildHelper.android_app?(filename)
              build.file_name = filename.gsub(/.*\.apk/i, "#{BuildHelper.generate_build_name(user.name, user.email)}.apk")
              
              path_to_file = File.join(FlyingApk::FILES_DIR, build.file_name)
              
              File.open(path_to_file, 'wb') { |f| f.write(tempfile.read) }
              
              build.file_checksum = BuildHelper.get_build_hash(path_to_file)
              build.created_time = Time.now
              
              build.save
              
              return ApiHelper.response(200) do
                 { api_version: API_VERSION, response: { build: { id: build.id, version: build.version, fixes: build.fixes, file_name: build.file_name, file_checksum: build.file_checksum } } }
              end
            end
          else
            return ApiHelper.response(500) do
              { api_version: API_VERSION, response: { errors: [ "file was not uploaded" ] } }
            end
          end
        else
          return ApiHelper.response(500) do
            { api_version: API_VERSION, response: { errors: build.errors.full_messages.uniq } }
          end
        end
      else
        return ApiHelper.response(403) do
          { api_version: API_VERSION, response: { errors: [ "you don't have permission to this resource" ] } }
        end
      end
    end
  end
end
