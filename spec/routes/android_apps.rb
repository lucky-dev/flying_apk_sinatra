require 'spec_helper'

describe AndroidApp do
  
   describe "is not created" do
     
     before do
       DB[:permission_apps].delete
       DB[:android_apps].delete
       DB[:users].delete
     end
     
     describe "when user is not authorized" do
       
       it "and an app has all params" do
         header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
       
         post "/android_apps", { "name" => "Cool App", "description" => "My Cool App" }, header
       
         expect(last_response.status).to eq(401)

         json_response = JSON.parse(last_response.body)

         expect(json_response["response"]["errors"]).to include("user is unauthorized")
       end
       
       it "and an app has no params" do
         @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
       
         post "/android_apps", {}, @header

         expect(last_response.status).to eq(401)

         json_response = JSON.parse(last_response.body)

         expect(json_response["response"]["errors"]).to include("user is unauthorized")
       end
       
     end
     
     describe "when user is authorized" do
       
       it "and an app has no name" do
         @user = User.new(name: "Bob", email: "test@example.com", password: "1234567")
         @user.save
         
         @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1", "HTTP_AUTHORIZATION" => @user.access_token }
       
         post "/android_apps", { "description" => "My Cool App" }, @header

         expect(last_response.status).to eq(500)

         json_response = JSON.parse(last_response.body)

         expect(json_response["response"]["errors"]).to include("name is not present")
       end
       
     end
     
   end
   
   describe "is created" do
     
     before do
       DB[:permission_apps].delete
       DB[:android_apps].delete
       DB[:users].delete
     end
     
     it "when user is authorized and an app has all params" do
       @user = User.new(name: "Bob", email: "test@example.com", password: "1234567")
       @user.save
       
       header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1", "HTTP_AUTHORIZATION" => @user.access_token }
     
       post "/android_apps", { "name" => "Cool App", "description" => "My Cool App" }, header
     
       expect(last_response.status).to eq(200)

       json_response = JSON.parse(last_response.body)

       expect(json_response["response"]).to include("android_app")
       expect(@user.permission_apps.size).to eq(1)
     end
     
   end
  
end
