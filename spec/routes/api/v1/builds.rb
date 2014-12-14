require_relative '../../../spec_helper'

describe Build do
  
  before do
    @header = { 'HTTP_ACCEPT' => 'application/vnd.flyingapk; version=1' }
  end
  
   describe 'is not created' do

     describe 'when user is not authorized' do

       it 'and the build has all params' do
         post '/api/builds?app_id=1', { 'version' => '1.0', 'fixes' => 'Some fixes', 'file' => Rack::Test::UploadedFile.new(MY_APP_FILE, 'application/vnd.android.package-archive') }, @header

         expect(last_response.status).to eq(401)

         json_response = JSON.parse(last_response.body)

         expect(json_response['response']['errors']).to include('user is unauthorized')
       end

       it 'and the build has no params' do
         post '/api/builds', {}, @header

         expect(last_response.status).to eq(401)

         json_response = JSON.parse(last_response.body)

         expect(json_response['response']['errors']).to include('user is unauthorized')
       end

     end

     describe 'when user is authorized' do

       before do
         DB[:permission_apps].delete
         DB[:access_tokens].delete
         DB[:builds].delete
         DB[:android_apps].delete
         DB[:users].delete
       end

       it 'and the build has no fixes' do
         user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
         app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
         PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')
         
         access_token = UserHelper.generate_access_token(user.name, user.email)
         user.add_access_token(access_token: access_token)

         @header['HTTP_AUTHORIZATION'] = access_token

         post "/api/builds?app_id=#{app.id}", { 'version' => '1.0', 'file' => Rack::Test::UploadedFile.new(MY_APP_FILE, 'application/vnd.android.package-archive') }, @header

         expect(last_response.status).to eq(500)

         json_response = JSON.parse(last_response.body)

         expect(json_response['response']['errors']).to include('fixes is not present')
       end
       
       it 'it has read only permission' do
         user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
         app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
         PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ')
         
         access_token = UserHelper.generate_access_token(user.name, user.email)
         user.add_access_token(access_token: access_token)

         @header['HTTP_AUTHORIZATION'] = access_token

         post "/api/builds?app_id=#{app.id}", { 'version' => '1.0', 'file' => Rack::Test::UploadedFile.new(MY_APP_FILE, 'application/vnd.android.package-archive') }, @header

         expect(last_response.status).to eq(403)

         json_response = JSON.parse(last_response.body)

         expect(json_response['response']['errors']).to include('you do not have permission to this resource')
       end

     end

   end
   
   describe 'is created' do
     
     before do
       DB[:permission_apps].delete
       DB[:access_tokens].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete
     end
     
     it 'when user is authorized and the build has all params' do       
       user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
       app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')
       
       access_token = UserHelper.generate_access_token(user.name, user.email)
       user.add_access_token(access_token: access_token)
       
       @header['HTTP_AUTHORIZATION'] = access_token
     
       post "/api/builds?app_id=#{app.id}", { 'version' => '1.0', 'fixes' => 'Some fixes', 'file' => Rack::Test::UploadedFile.new(MY_APP_FILE, 'application/vnd.android.package-archive') }, @header
     
       expect(last_response.status).to eq(200)

       json_response = JSON.parse(last_response.body)

       expect(json_response['response']).to include('build')

       path_to_file = File.join(FlyingApk::App::FILES_DIR, json_response['response']['build']['file_name'])
       expect(File.exist?(path_to_file)).to be(true)
     end
     
   end
   
   describe 'is gotten by' do
     
     before do
       DB[:permission_apps].delete
       DB[:access_tokens].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete

       @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
     end

     it 'an authorized user' do
       app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
       access_token = UserHelper.generate_access_token(@user.name, @user.email)
       @user.add_access_token(access_token: access_token)
       3.times do |index|
         build = Build.new(version: "#{index}.0", fixes: 'Some fixes', created_time: Time.now.utc, file_name: 'my_app_#{index}.apk', file_checksum: 'ea6e9d41130509444421709610432ee1')
         app.add_build(build)
       end

       @header['HTTP_AUTHORIZATION'] = access_token

       get "/api/builds?app_id=#{app.id}", {}, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(200)

       expect(json_response['response']['builds'].size).to eq(3)
     end

     it 'an unauthorized user' do
       app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')

       get "/api/builds?app_id=#{app.id}", {}, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(401)

       expect(json_response['response']['errors']).to include('user is unauthorized')
     end

     it 'an other user' do
       app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
       3.times do |index|
         build = Build.new(version: "#{index}.0", fixes: 'Some fixes', created_time: Time.now.utc, file_name: "my_app_#{index}.apk", file_checksum: 'ea6e9d41130509444421709610432ee1')
         app.add_build(build)
       end

       other_user = User.create(name: 'Mike', email: 'mike@example.com', password: '1234567')
       access_token = UserHelper.generate_access_token(other_user.name, other_user.email)
       other_user.add_access_token(access_token: access_token)

       @header['HTTP_AUTHORIZATION'] = access_token

       get "/api/builds?app_id=#{app.id}", {}, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(403)

       expect(json_response['response']['errors']).to include('you do not have permission to this resource')
     end

   end
   
   describe 'is updated by' do

     before do
       DB[:permission_apps].delete
       DB[:access_tokens].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete

       @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
     end

     it 'an authorized user who has all permissions' do
       app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
       access_token = UserHelper.generate_access_token(@user.name, @user.email)
       @user.add_access_token(access_token: access_token)
       build = Build.new(version: '1.0', fixes: 'Some fixes', created_time: Time.now.utc, file_name: 'my_app.apk', file_checksum: 'ea6e9d41130509444421709610432ee1')
       app.add_build(build)

       @header['HTTP_AUTHORIZATION'] = access_token

       put "/api/builds/#{build.id}", { fixes: 'Amazing fixes' }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(200)

       expect(json_response['response']['build']['version']).to eq('1.0')
       expect(json_response['response']['build']['fixes']).to eq('Amazing fixes')
     end

   end
   
   describe 'is not updated by' do

     before do
       DB[:permission_apps].delete
       DB[:access_tokens].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete

       @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
     end

     describe 'an authorized user' do

       it 'when fixes of the build is not present' do
         app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
         PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
         access_token = UserHelper.generate_access_token(@user.name, @user.email)
         @user.add_access_token(access_token: access_token)
         build = Build.new(version: '1.0', fixes: 'Some fixes', created_time: Time.now.utc, file_name: 'my_app.apk', file_checksum: 'ea6e9d41130509444421709610432ee1')
         app.add_build(build)

         @header['HTTP_AUTHORIZATION'] = access_token

         put "/api/builds/#{build.id}", { version: '1.0', fixes: '' }, @header

         json_response = JSON.parse(last_response.body)

         expect(last_response.status).to eq(500)

         expect(json_response['response']['errors']).to include('fixes is not present')
       end

       it 'when user has no permissions to this app' do
         app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
         PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
         build = Build.new(version: '1.0', fixes: 'Some fixes', created_time: Time.now.utc, file_name: 'my_app.apk', file_checksum: 'ea6e9d41130509444421709610432ee1')
         app.add_build(build)

         # Create an app for other user
         other_user = User.create(name: 'Mike', email: 'mike@example.com', password: '1234567')
         access_token = UserHelper.generate_access_token(other_user.name, other_user.email)
         other_user.add_access_token(access_token: access_token)

         @header['HTTP_AUTHORIZATION'] = access_token

         put "/api/builds/#{build.id}", {}, @header

         json_response = JSON.parse(last_response.body)

         expect(last_response.status).to eq(403)

         expect(json_response['response']['errors']).to include('you do not have permission to this resource')
       end

     end

     it 'an unauthorized user' do
       app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE') 
       build = Build.new(version: '1.0', fixes: 'Some fixes', created_time: Time.now.utc, file_name: 'my_app.apk', file_checksum: 'ea6e9d41130509444421709610432ee1')
       app.add_build(build)

       put "/api/builds/#{build.id}", {}, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(401)

       expect(json_response['response']['errors']).to include('user is unauthorized')
     end

   end
   
   describe 'is deleted by' do

     before do
       DB[:permission_apps].delete
       DB[:access_tokens].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete

       @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
     end

     it 'an authorized user who has all permissions' do
       app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
       access_token = UserHelper.generate_access_token(@user.name, @user.email)
       @user.add_access_token(access_token: access_token)
       build = Build.new(version: '1.0', fixes: 'Some fixes', created_time: Time.now.utc, file_name: 'my_app.apk', file_checksum: 'ea6e9d41130509444421709610432ee1')
       app.add_build(build)

       @header['HTTP_AUTHORIZATION'] = access_token

       delete "/api/builds/#{build.id}", {}, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(200)

       expect(json_response['response']['build']['id']).to eq(build.id)
     end

   end

   describe 'is not deleted by' do

     before do
       DB[:permission_apps].delete
       DB[:access_tokens].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete

       @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
     end

     describe 'an authorized user' do

       it 'who has no permissions to this app' do
         app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
         PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE') 
         build = Build.new(version: '1.0', fixes: 'Some fixes', created_time: Time.now.utc, file_name: 'my_app.apk', file_checksum: 'ea6e9d41130509444421709610432ee1')
         app.add_build(build)
         
         # Create an app for other user
         other_user = User.create(name: 'Mike', email: 'mike@example.com', password: '1234567')
         access_token = UserHelper.generate_access_token(other_user.name, other_user.email)
         other_user.add_access_token(access_token: access_token)

         @header['HTTP_AUTHORIZATION'] = access_token

         delete "/api/builds/#{build.id}", {}, @header

         json_response = JSON.parse(last_response.body)

         expect(last_response.status).to eq(403)

         expect(json_response['response']['errors']).to include('you do not have permission to this resource')
        end
      end

     it 'an unauthorized user' do
       app = AndroidApp.create(name: 'My cool app', description: 'Cool app')
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE') 
       build = Build.new(version: '1.0', fixes: 'Some fixes', created_time: Time.now.utc, file_name: 'my_app.apk', file_checksum: 'ea6e9d41130509444421709610432ee1')
       app.add_build(build)

       put "/api/builds/#{build.id}", {}, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(401)

       expect(json_response['response']['errors']).to include('user is unauthorized')
     end

   end
   
end
