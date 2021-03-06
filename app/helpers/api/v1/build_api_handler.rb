module ApiV1
  module BuildApiHandler
    def self.create_build(user, params)
      version = params[:version]
      fixes = params[:fixes]
      type = params[:type]
      app_id = params[:app_id]
      file = params[:file]
    
      permission_for_app = user.permission_apps_dataset.where(android_app_id: app_id, permission: 'READ_WRITE').first
      if permission_for_app
        build = Build.new(version: version, fixes: fixes, type: type)
      
        if build.valid?
          if file
            filename = file[:filename]
            tempfile = file[:tempfile]
          
            if BuildHelper.android_app?(filename)
              build.file_name = filename.gsub(/.*\.apk/i, "#{BuildHelper.generate_build_name(user.name, user.email)}.apk")
            
              path_to_file = File.join(FlyingApk::App::FILES_DIR, build.file_name)
            
              File.open(path_to_file, 'wb') { |f| f.write(tempfile.read) }

              # Get number of builds for certain app
              count_builds = Build.where(android_app_id: app_id).count

              build.name = "Build ##{count_builds + 1}"
              build.file_checksum = BuildHelper.get_build_hash(path_to_file)
              build.created_time = Time.now.utc
              build.android_app_id = app_id
            
              build.save

              MailNotificationHelper.perform_async(:add_new_build, app_id, build.id)
            
              return ApiHelper.response(200) do
                 { api_version: API_VERSION, response: { build: { id: build.id, name: build.name, version: build.version, fixes: build.fixes, created_time: build.created_time, file_name: build.file_name, file_checksum: build.file_checksum } } }
              end
            end
          else
            return ApiHelper.response(500) do
              { api_version: API_VERSION, response: { errors: [ 'file was not uploaded' ] } }
            end
          end
        else
          return ApiHelper.response(500) do
            { api_version: API_VERSION, response: { errors: build.errors.full_messages.uniq } }
          end
        end
      else
        return ApiHelper.response(403) do
          { api_version: API_VERSION, response: { errors: [ 'you do not have permission to this resource' ] } }
        end
      end
    end
    
    def self.get_builds(user, params)
      app_id = params[:app_id]
      type = params[:type]
    
      permission_for_app = user.permission_apps_dataset.where(android_app_id: app_id).first
      if permission_for_app
        query_get_builds = ((type == 'debug') || (type == 'release')) ? Build.where(android_app_id: app_id, type: type) : Build.where(android_app_id: app_id)
        all_builds = query_get_builds.reverse_order(:created_time).all

        builds = []
        all_builds.each do |build|
          builds << { id: build.id, name: build.name, version: build.version, fixes: build.fixes, type: build.type, created_time: build.created_time, file_name: build.file_name, file_checksum: build.file_checksum }
        end

        return ApiHelper.response(200) do
          { api_version: API_VERSION, response: { builds: builds } }
        end
      else
        return ApiHelper.response(403) do
          { api_version: API_VERSION, response: { errors: [ 'you do not have permission to this resource' ] } }
        end
      end
    end
  
    def self.update_build(user, params)
      id = params[:id]
      version = params[:version]
      fixes = params[:fixes]
      type = params[:type]
    
      build = Build.where(id: id).first

      permission_for_app = user.permission_apps_dataset.where(android_app_id: (build ? build.android_app.id : -1), permission: 'READ_WRITE').first
      if permission_for_app
        build.version = version || build.version
        build.fixes = fixes || build.fixes
        build.type = type || build.type
      
        if build.valid?
          build.save
          return ApiHelper.response(200) do
            { api_version: API_VERSION, response: { build: { id: build.id, name: build.name, version: build.version, fixes: build.fixes, type: build.type, created_time: build.created_time, file_name: build.file_name, file_checksum: build.file_checksum } } }
          end
        else
          return ApiHelper.response(500) do
            { api_version: API_VERSION, response: { errors: build.errors.full_messages.uniq } }
          end
        end
      else
        return ApiHelper.response(403) do
          { api_version: API_VERSION, response: { errors: [ 'you do not have permission to this resource' ] } }
        end
      end
    end
  
    def self.delete_build(user, params)
      id = params[:id]
    
      build = Build.where(id: id).first

      permission_for_app = user.permission_apps_dataset.where(android_app_id: (build ? build.android_app.id : -1), permission: 'READ_WRITE').first
      if permission_for_app
        # Remove the build which is related with this app
        build.delete
      
        return ApiHelper.response(200) do
          { api_version: API_VERSION, response: { build: { id: build.id } } }
        end
      else
        return ApiHelper.response(403) do
          { api_version: API_VERSION, response: { errors: [ 'you do not have permission to this resource' ] } }
        end
      end
    end
  end
end
