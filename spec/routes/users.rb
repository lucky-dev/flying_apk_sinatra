require 'spec_helper'
require 'pry'

describe User do
  before do    
    @method = "/register"
    @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
  end

  describe "is not created" do

    it "when header is empty" do
      post @method
      
      expect(last_response.status).to eq(406)
  
      json_response = JSON.parse(last_response.body)
      
      expect(json_response["response"]["errors"]).to include("bad header")
    end

    it "when name is not valid" do
      post @method , { "email" => "test@example.com", "password" => "1234567" }, @header

      expect(last_response.status).to eq(500)
  
      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]["errors"]).to include("name is not present")
    end
    
    describe "when email" do
      
      it "is not present" do
        post @method, { "name" => "test", "password" => "1234567" }, @header

        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response["response"]["errors"]).to include("email is not present")
      end
      
      it "is invalid" do
        post '/register' , { "name" => "test", "email" => "test_example.com", "password" => "1234567" }, @header
        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response["response"]["errors"]).to include("email is invalid")
      end
      
      it "is already taken" do
        DB[:permission_apps].delete
        DB[:users].delete
        
        user = User.new(name: "Bob", email: "test@example.com", password: "1234567")
        user.save
        
        post @method , { "name" => "test", "email" => "test@example.com", "password" => "1234567" }, @header

        expect(last_response.status).to eq(500)

        json_response = JSON.parse(last_response.body)

        expect(json_response["response"]["errors"]).to include("email is already taken")
      end
      
    end
    
    describe "when password" do
      
      it "is not present" do
        post @method, { "name" => "test", "email" => "test@example.com" }, @header

        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response["response"]["errors"]).to include("password is not present")
      end
      
      it "is too short" do
        post @method , { "name" => "test", "email" => "test_example.com", "password" => "123" }, @header
        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response["response"]["errors"]).to include("password is shorter than 6 characters")
      end
      
    end

  end
  
  describe "is created" do
    before do
      DB[:permission_apps].delete
      DB[:users].delete
    end

    it "when all fields are valid" do      
      post @method , { "name" => "test", "email" => "test@example.com", "password" => "1234567" }, @header

      expect(last_response.status).to eq(200)

      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]).to include("access_token")
    end
    
  end

end
