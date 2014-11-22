require 'spec_helper'

describe Build do
  
   # describe "is not created" do
   #
   #   describe "when user is not authorized" do
   #
   #     before do
   #       DB[:permission_apps].delete
   #       DB[:android_apps].delete
   #       DB[:users].delete
   #     end
   #
   #     it "and an app has all params" do
   #       header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
   #
   #       post "/android_apps", { "name" => "Cool App", "description" => "My Cool App" }, header
   #
   #       expect(last_response.status).to eq(401)
   #
   #       json_response = JSON.parse(last_response.body)
   #
   #       expect(json_response["response"]["errors"]).to include("user is unauthorized")
   #     end
   #
   #     it "and an app has no params" do
   #       @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
   #
   #       post "/android_apps", {}, @header
   #
   #       expect(last_response.status).to eq(401)
   #
   #       json_response = JSON.parse(last_response.body)
   #
   #       expect(json_response["response"]["errors"]).to include("user is unauthorized")
   #     end
   #
   #   end
   #
   #   describe "when user is authorized" do
   #
   #     before do
   #       DB[:permission_apps].delete
   #       DB[:android_apps].delete
   #       DB[:users].delete
   #     end
   #
   #     it "and an app has no name" do
   #       @user = User.new(name: "Bob", email: "test@example.com", password: "1234567")
   #       @user.save
   #
   #       @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1", "HTTP_AUTHORIZATION" => @user.access_token }
   #
   #       post "/android_apps", { "description" => "My Cool App" }, @header
   #
   #       expect(last_response.status).to eq(500)
   #
   #       json_response = JSON.parse(last_response.body)
   #
   #       expect(json_response["response"]["errors"]).to include("name is not present")
   #     end
   #
   #   end
   #
   # end
   
   describe "is created" do
     
     before do
       DB[:permission_apps].delete
       DB[:builds].delete
       DB[:android_apps].delete
       DB[:users].delete
     end
     
     it "when user is authorized and an app has all params" do       
       user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
       app = AndroidApp.create(name: "My cool app", description: "Cool app")
       PermissionApp.create(user_id: user.id, android_app_id: app.id, permission: 'READ_WRITE')
       
       header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1", "HTTP_AUTHORIZATION" => user.access_token }
     
       post "/builds?app_id=#{app.id}", { "version" => "1.0", "fixes" => "Some fixes", "file" => Rack::Test::UploadedFile.new(MY_APP_FILE, "application/vnd.android.package-archive") }, header
     
       expect(last_response.status).to eq(200)

       json_response = JSON.parse(last_response.body)

       expect(json_response["response"]).to include("build")
     end
     
   end
   
   # describe "is gotten by" do
#      before do
#        DB[:permission_apps].delete
#        DB[:android_apps].delete
#        DB[:users].delete
#
#        @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
#
#        @user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
#      end
#
#      it "an authorized user" do
#        3.times do |index|
#          app = AndroidApp.create(name: "My cool app #{index}", description: "Cool app")
#          PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
#        end
#
#        # Create an app for other user
#        other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")
#        app = AndroidApp.create(name: "My cool app 100", description: "Cool app")
#        PermissionApp.create(user_id: other_user.id, android_app_id: app.id, permission: 'READ')
#
#        @header["HTTP_AUTHORIZATION"] = @user.access_token
#
#        get "/android_apps", {}, @header
#
#        json_response = JSON.parse(last_response.body)
#
#        expect(last_response.status).to eq(200)
#
#        expect(json_response["response"]["apps"].size).to eq(3)
#      end
#
#      it "an unauthorized user" do
#        get "/android_apps", {}, @header
#
#        json_response = JSON.parse(last_response.body)
#
#        expect(last_response.status).to eq(401)
#
#        expect(json_response["response"]["errors"]).to include("user is unauthorized")
#      end
#
#    end
   
   # describe "is updated by" do
#
#      before do
#        DB[:permission_apps].delete
#        DB[:android_apps].delete
#        DB[:users].delete
#
#        @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
#
#        @user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
#      end
#
#      it "an authorized user who has all permissions" do
#        app = AndroidApp.create(name: "My cool app", description: "Cool app")
#        PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
#
#        @header["HTTP_AUTHORIZATION"] = @user.access_token
#
#        put "/android_apps/#{app.id}", { description: "Amazing app" }, @header
#
#        json_response = JSON.parse(last_response.body)
#
#        expect(last_response.status).to eq(200)
#
#        expect(json_response["response"]["app"]["name"]).to eq("My cool app")
#        expect(json_response["response"]["app"]["description"]).to eq("Amazing app")
#      end
#
#    end
   
   # describe "is not updated by" do
#
#      before do
#        DB[:permission_apps].delete
#        DB[:android_apps].delete
#        DB[:users].delete
#
#        @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
#
#        @user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
#      end
#
#      describe "an authorized user" do
#
#        it "when then name of the app is not present" do
#          app = AndroidApp.create(name: "My cool app", description: "Cool app")
#          PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
#
#          @header["HTTP_AUTHORIZATION"] = @user.access_token
#
#          put "/android_apps/#{app.id}", { name: "", description: "Amazing app" }, @header
#
#          json_response = JSON.parse(last_response.body)
#
#          expect(last_response.status).to eq(500)
#
#          expect(json_response["response"]["errors"]).to include("name is not present")
#        end
#
#        it "when user has no permissions to this app" do
#          app = AndroidApp.create(name: "My cool app", description: "Cool app")
#          PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ')
#
#          # Create an app for other user
#          other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")
#
#          @header["HTTP_AUTHORIZATION"] = other_user.access_token
#
#          put "/android_apps/#{app.id}", {}, @header
#
#          json_response = JSON.parse(last_response.body)
#
#          expect(last_response.status).to eq(403)
#
#          expect(json_response["response"]["errors"]).to include("you don't have permission to this resource")
#        end
#
#      end
#
#      it "an unauthorized user" do
#        app = AndroidApp.create(name: "My cool app", description: "Cool app")
#        PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
#
#        put "/android_apps/#{app.id}", {}, @header
#
#        json_response = JSON.parse(last_response.body)
#
#        expect(last_response.status).to eq(401)
#
#        expect(json_response["response"]["errors"]).to include("user is unauthorized")
#      end
#
#    end
   
   # describe "is deleted by" do
#
#      before do
#        DB[:permission_apps].delete
#        DB[:android_apps].delete
#        DB[:users].delete
#
#        @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
#
#        @user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
#      end
#
#      it "an authorized user who has all permissions" do
#        app = AndroidApp.create(name: "My cool app", description: "Cool app")
#        PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
#
#        @header["HTTP_AUTHORIZATION"] = @user.access_token
#
#        delete "/android_apps/#{app.id}", {}, @header
#
#        json_response = JSON.parse(last_response.body)
#
#        expect(last_response.status).to eq(200)
#
#        expect(json_response["response"]["app"]["id"]).to eq(app.id)
#      end
#
#    end

   # describe "is not deleted by" do
#
#      before do
#        DB[:permission_apps].delete
#        DB[:android_apps].delete
#        DB[:users].delete
#
#        @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
#
#        @user = User.create(name: "Bob", email: "test@example.com", password: "1234567")
#      end
#
#      describe "an authorized user" do
#
#        it "who has no permissions to this app" do
#          app = AndroidApp.create(name: "My cool app", description: "Cool app")
#          PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ')
#
#          # Create an app for other user
#          other_user = User.create(name: "Mike", email: "mike@example.com", password: "1234567")
#
#          @header["HTTP_AUTHORIZATION"] = other_user.access_token
#
#          delete "/android_apps/#{app.id}", {}, @header
#
#          json_response = JSON.parse(last_response.body)
#
#          expect(last_response.status).to eq(403)
#
#          expect(json_response["response"]["errors"]).to include("you don't have permission to this resource")
#         end
#       end
#
#      it "an unauthorized user" do
#        app = AndroidApp.create(name: "My cool app", description: "Cool app")
#        PermissionApp.create(user_id: @user.id, android_app_id: app.id, permission: 'READ_WRITE')
#
#        put "/android_apps/#{app.id}", {}, @header
#
#        json_response = JSON.parse(last_response.body)
#
#        expect(last_response.status).to eq(401)
#
#        expect(json_response["response"]["errors"]).to include("user is unauthorized")
#      end
#
#    end
   
end
