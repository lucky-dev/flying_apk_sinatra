require 'spec_helper'

describe User do
  before do
    @header = { "HTTP_ACCEPT" => "application/vnd.flyingapp; version=1" }
  end

  describe "is not created" do

    it "when header is empty" do
      post "/register"
      
      expect(last_response.status).to eq(406)
  
      json_response = JSON.parse(last_response.body)
      
      expect(json_response["response"]["errors"]).to include("bad header")
    end

    it "when name is not valid" do
      post "/register" , { "email" => "test@example.com", "password" => "1234567" }, @header

      expect(last_response.status).to eq(500)
  
      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]["errors"]).to include("name is not present")
    end
    
    describe "when email" do
      
      it "is not present" do
        post "/register", { "name" => "test", "password" => "1234567" }, @header

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
        
        post "/register", { "name" => "test", "email" => "test@example.com", "password" => "1234567" }, @header

        expect(last_response.status).to eq(500)

        json_response = JSON.parse(last_response.body)

        expect(json_response["response"]["errors"]).to include("email is already taken")
      end
      
    end
    
    describe "when password" do
      
      it "is not present" do
        post "/register", { "name" => "test", "email" => "test@example.com" }, @header

        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response["response"]["errors"]).to include("password is not present")
      end
      
      it "is too short" do
        post "/register", { "name" => "test", "email" => "test_example.com", "password" => "123" }, @header
        
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
      post "/register", { "name" => "test", "email" => "test@example.com", "password" => "1234567" }, @header

      expect(last_response.status).to eq(200)

      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]).to include("access_token")
    end
    
  end
  
  describe "does not enter in the system" do
    before do
      DB[:permission_apps].delete
      DB[:users].delete

      user = User.new(name: "Bob", email: "test@example.com", password: "1234567")
      user.save
    end
    
    it "when email is wrong" do
      post "/login", { "email" => "test123@example.com", "password" => "1234567" }, @header
      
      expect(last_response.status).to eq(500)

      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]["errors"]).to include("email is not found")
    end
    
    it "when email is nil" do
      post "/login", { "password" => "1234567" }, @header
      
      expect(last_response.status).to eq(500)

      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]["errors"]).to include("email is not found")
    end
    
    it "when password does not match" do
      post "/login", { "email" => "test@example.com", "password" => "12345678" }, @header
      
      expect(last_response.status).to eq(500)

      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]["errors"]).to include("password is wrong")
    end
    
    it "when password is nil" do
      post "/login", { "email" => "test@example.com"}, @header
      
      expect(last_response.status).to eq(500)

      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]["errors"]).to include("password is wrong")
    end
    
  end
  
  describe "enters in the system" do    
    before do
      DB[:permission_apps].delete
      DB[:users].delete

      user = User.new(name: "Bob", email: "test@example.com", password: "1234567")
      user.save
    end
    
    it "when email and password are right" do      
      post "/login", { "email" => "test@example.com", "password" => "1234567"}, @header
      
      expect(last_response.status).to eq(200)

      json_response = JSON.parse(last_response.body)

      expect(json_response["response"]).to include("access_token")
    end
  end

end