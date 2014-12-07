module ApiV1
  module AndroidAppApiHandler
    def self.create(user, params)
      name = params[:name]
      description = params[:description]

      android_app = AndroidApp.new(name: name, description: description)
      if android_app.valid?
        android_app.save
      
        PermissionApp.create(user_id: user.id, android_app_id: android_app.id, permission: 'READ_WRITE')
      
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
      all_apps = AndroidApp.where(id: user.permission_apps_dataset.select(:android_app_id)).order(:name).all
    
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
          android_app.save
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
      
        # Remove permissions for all users
        PermissionApp.where(android_app_id: id).delete
        # Remove all builds which are related with this app
        Build.where(android_app_id: id).delete
        # Remove this app
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
  
    def self.add_user_to_app(user, params)
      app_id = params[:id]
      email = params[:email]
    
      permission_for_app = user.permission_apps_dataset.where(android_app_id: app_id, permission: 'READ_WRITE').first
      if permission_for_app
        if email && (email != user.email)
          new_user = User.where(email: email).first
        
          if new_user
            existing_permission_new_user = new_user.permission_apps_dataset.where(android_app_id: app_id).first
        
            unless existing_permission_new_user
              permission = PermissionApp.create(user_id: new_user.id, android_app_id: app_id, permission: 'READ')
              return ApiHelper.response(200) do
                { api_version: API_VERSION, response: { permission: { user_id: permission.user_id } } }
              end
            else
              return ApiHelper.response(500) do
                { api_version: API_VERSION, response: { errors: [ "the permission exists" ] } }
              end
            end
          else
            return ApiHelper.response(500) do
              { api_version: API_VERSION, response: { errors: [ "email is not exist" ] } }
            end
          end
        else
          return ApiHelper.response(500) do
            { api_version: API_VERSION, response: { errors: [ "this email can't be used" ] } }
          end
        end
      else
        return ApiHelper.response(403) do
          { api_version: API_VERSION, response: { errors: [ "you don't have permission to this resource" ] } }
        end
      end
    end
  
    def self.remove_user_from_app(user, params)
      app_id = params[:id]
      email = params[:email]
    
      permission_for_app = user.permission_apps_dataset.where(android_app_id: app_id, permission: 'READ_WRITE').first
      if permission_for_app
        if email && (email != user.email)
          new_user = User.where(email: email).first
        
          if new_user
            existing_permission_new_user = new_user.permission_apps_dataset.where(android_app_id: app_id).first
            if existing_permission_new_user
              existing_permission_new_user.delete
              return ApiHelper.response(200) do
                { api_version: API_VERSION, response: { permission: { user_id: new_user.id } } }
              end
            else
              return ApiHelper.response(500) do
                { api_version: API_VERSION, response: { errors: [ "the permission is not exist" ] } }
              end
            end
          else
            return ApiHelper.response(500) do
              { api_version: API_VERSION, response: { errors: [ "email is not exist" ] } }
            end
          end
        else
          return ApiHelper.response(500) do
            { api_version: API_VERSION, response: { errors: [ "this email can't be used" ] } }
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
