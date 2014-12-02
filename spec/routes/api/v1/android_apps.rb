require_relative '../../../spec_helper'

describe AndroidApp do
  
  before do
    @header = { "HTTP_ACCEPT" => "application/vnd.flyingapk; version=1" }
  end
  
   describe "is not created" do
     
     describe "when user is not authorized" do
       
       it "and an app has all params" do
         post "/api/android_apps", { "name" => "Cool App", "description" => "My Cool App" }, @header
       
         expect(last_response.status).to eq(401)

         json_response = JSON.parse(last_response.body)

         expect(json_response["response"]["errors"]).to include("user is unauthorized")
       end
       
       it "and an app has no params" do       
         post "/api/android_apps", {}, @header

         expect(last_response.status).to eq(401)

         json_response = JSON.parse(last_response.body)

         expect(json_response["response"]["errors"]).to include("user is unauthorized")
       end
       
     end
     
     describe "when user is authorized" do
       
       before do
         DB[:permission_apps].delete
         DB[:builds].delete
         DB[:android_apps].delete
         DB[:users].delete
       end
       
       it "and an app has no name" do
         user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
         
         @header["HTTP_AUTHORIZATION"] = user.access_token
       
         post "/api/android_apps", { "description" => "My Cool App" }, @header

         expect(last_response.status).to eq(500)

         json_response = JSON.parse(last_response.body)

         expect(json_response["response"]["errors"]).to include("name is not present")
       end
       
     end
     
   end
   
   describe "is created" do
     
     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete
     end
     
     it "when user is authorized and an app has all params" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       
       @header["HTTP_AUTHORIZATION"] = user.access_token
     
       post "/api/android_apps", { "name" => "Cool App", "description" => "My Cool App" }, @header
     
       expect(last_response.status).to eq(200)

       json_response = JSON.parse(last_response.body)

       expect(json_response["response"]).to include("android_app")
       expect(user.permission_apps.size).to eq(1)
     end
     
   end
   
   describe "is gotten by" do
     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete

       @user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
     end
     
     it "an authorized user" do
       3.times do |index|
         app = AndroidApp.create(name: "My cool app #{index}", description: "Cool app")      
         PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
       end
      
       # Create an app for other user
       other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app 100", description: "Cool app")      
       PermissionApp.create(user_id: other_user.id, android_app_id: app.id, permission: 'READ')
      
       @header["HTTP_AUTHORIZATION"] = @user.access_token

       get "/api/android_apps", {}, @header
      
       json_response = JSON.parse(last_response.body)
      
       expect(last_response.status).to eq(200)
      
       expect(json_response["response"]["apps"].size).to eq(3)
     end
     
     it "an unauthorized user" do
       get "/api/android_apps", {}, @header
      
       json_response = JSON.parse(last_response.body)
      
       expect(last_response.status).to eq(401)
      
       expect(json_response["response"]["errors"]).to include("user is unauthorized")
     end
     
   end
   
   describe "is updated by" do
     
     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete
     end
     
     it "an authorized user who has all permissions" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')

       @header["HTTP_AUTHORIZATION"] = user.access_token

       put "/api/android_apps/#{app.id}", { description: "Amazing app" }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(200)

       expect(json_response["response"]["app"]["name"]).to eq("My cool app")
       expect(json_response["response"]["app"]["description"]).to eq("Amazing app")
     end
     
   end
   
   describe "is not updated by" do
     
     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete

       @user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
     end
     
     describe "an authorized user" do
       
       it "when name of the app is not present" do
         app = AndroidApp.create(name: "My cool app", description: "Cool app")
         PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')

         @header["HTTP_AUTHORIZATION"] = @user.access_token

         put "/api/android_apps/#{app.id}", { name: "", description: "Amazing app" }, @header

         json_response = JSON.parse(last_response.body)

         expect(last_response.status).to eq(500)

         expect(json_response["response"]["errors"]).to include("name is not present")
       end
       
       it "when user has no permissions to this app" do
         app = AndroidApp.create(name: "My cool app", description: "Cool app")
         PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ')
         
         # Create an app for other user
         other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")

         @header["HTTP_AUTHORIZATION"] = other_user.access_token

         put "/api/android_apps/#{app.id}", {}, @header

         json_response = JSON.parse(last_response.body)

         expect(last_response.status).to eq(403)

         expect(json_response["response"]["errors"]).to include("you don't have permission to this resource")
       end
       
     end
     
     it "an unauthorized user" do       
       app = AndroidApp.create(name: "My cool app", description: "Cool app")      
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
       
       put "/api/android_apps/#{app.id}", {}, @header
      
       json_response = JSON.parse(last_response.body)
      
       expect(last_response.status).to eq(401)
      
       expect(json_response["response"]["errors"]).to include("user is unauthorized")
     end
     
   end
   
   describe "is deleted by" do
     
     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete
     end
     
     it "an authorized user who has all permissions" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')

       @header["HTTP_AUTHORIZATION"] = user.access_token

       delete "/api/android_apps/#{app.id}", {}, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(200)

       expect(PermissionApp.where(android_app_id: app.id).all.size).to eq(0)
       expect(json_response["response"]["app"]["id"]).to eq(app.id)
     end
     
   end

   describe "is not deleted by" do

     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete

       @user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
     end
     
     describe "an authorized user" do
       
       it "who has no permissions to this app" do
         app = AndroidApp.create(name: "My cool app", description: "Cool app")
         PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ')
         
         # Create an app for other user
         other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")

         @header["HTTP_AUTHORIZATION"] = other_user.access_token

         delete "/api/android_apps/#{app.id}", {}, @header

         json_response = JSON.parse(last_response.body)

         expect(last_response.status).to eq(403)

         expect(json_response["response"]["errors"]).to include("you don't have permission to this resource")
        end
      end

     it "an unauthorized user" do
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')

       put "/api/android_apps/#{app.id}", {}, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(401)

       expect(json_response["response"]["errors"]).to include("user is unauthorized")
     end

   end
   
   describe "has been accessible yet" do
     
     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete
     end
     
     it "because admin adds the user" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')
     
       # Create an app for other user
       other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")
     
       expect(other_user.permission_apps.size).to eq(0)

       @header["HTTP_AUTHORIZATION"] = user.access_token

       post "/api/android_apps/#{app.id}/add_user", { email: other_user.email }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(200)

       other_user.reload
       
       expect(other_user.permission_apps.size).to eq(1)
       expect(json_response["response"]["permission"]["user_id"]).to eq(other_user.id)
     end
     
     it "because admin tries to add the existing user" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')
     
       # Create an app for other user
       other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")
       PermissionApp.create(user_id: other_user.id, android_app_id: app.id, permission: 'READ')

       @header["HTTP_AUTHORIZATION"] = user.access_token

       post "/api/android_apps/#{app.id}/add_user", { email: other_user.email }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(500)

       expect(json_response["response"]["errors"]).to include("the permission exists")
     end
     
     it "because admin tries to add yourself to the app" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')

       @header["HTTP_AUTHORIZATION"] = user.access_token

       post "/api/android_apps/#{app.id}/add_user", { email: user.email }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(500)

       expect(json_response["response"]["errors"]).to include("this email can't be used")
     end
     
   end
   
   describe "has not been accessible" do

     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete
     end

     it "because admin removes an user" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')

       # Create an app for other user
       other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")
       PermissionApp.create(user_id: other_user.id, android_app_id: app.id, permission: 'READ')

       expect(other_user.permission_apps.size).to eq(1)

       @header["HTTP_AUTHORIZATION"] = user.access_token

       post "/api/android_apps/#{app.id}/remove_user", { email: other_user.email }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(200)

       other_user.reload

       expect(other_user.permission_apps.size).to eq(0)
       expect(json_response["response"]["permission"]["user_id"]).to eq(other_user.id)
     end

     it "because admin tries to remove yourself from the app" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')

       @header["HTTP_AUTHORIZATION"] = user.access_token

       post "/api/android_apps/#{app.id}/remove_user", { email: user.email }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(500)

       expect(json_response["response"]["errors"]).to include("this email can't be used")
     end
    
     it "because admin has already removed this user" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')
       
       # Other user
       other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")

       @header["HTTP_AUTHORIZATION"] = user.access_token

       post "/api/android_apps/#{app.id}/remove_user", { email: "mike@example.com" }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(500)

       expect(json_response["response"]["errors"]).to include("the permission is not exist")
     end
     
     it "because admin tries to remove the user with invalid email" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')

       @header["HTTP_AUTHORIZATION"] = user.access_token

       post "/api/android_apps/#{app.id}/remove_user", { email: "mike@example.com" }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(500)

       expect(json_response["response"]["errors"]).to include("email is not exist")
     end
     
     it "because admin tries to add an user with invalid email" do
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')

       @header["HTTP_AUTHORIZATION"] = user.access_token

       post "/api/android_apps/#{app.id}/add_user", { email: "mike@example.com" }, @header

       json_response = JSON.parse(last_response.body)

       expect(last_response.status).to eq(500)

       expect(json_response["response"]["errors"]).to include("email is not exist")
     end

   end
   
end
