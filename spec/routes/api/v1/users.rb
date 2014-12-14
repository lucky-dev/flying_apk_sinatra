require_relative '../../../spec_helper'

describe User do
  before do
    @header = { 'HTTP_ACCEPT' => 'application/vnd.flyingapk; version=1' }
  end

  describe 'is not created' do

    it 'when header is empty' do
      post '/api/register'
      
      expect(last_response.status).to eq(406)
  
      json_response = JSON.parse(last_response.body)
      
      expect(json_response['response']['errors']).to include('bad header')
    end

    it 'when name is not valid' do
      post '/api/register' , { 'email' => 'test@example.com', 'password' => '1234567' }, @header

      expect(last_response.status).to eq(500)
  
      json_response = JSON.parse(last_response.body)

      expect(json_response['response']['errors']).to include('name is not present')
    end
    
    describe 'when email' do
      
      it 'is not present' do
        post '/api/register', { 'name' => 'test', 'password' => '1234567' }, @header

        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response['response']['errors']).to include('email is not present')
      end
      
      it 'is invalid' do
        post '/api/register' , { 'name' => 'test', 'email' => 'test_example.com', 'password' => '1234567' }, @header
        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response['response']['errors']).to include('email is invalid')
      end
      
      it 'is already taken' do
        DB[:permission_apps].delete
        DB[:access_tokens].delete
        DB[:users].delete
        
        user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
        
        post '/api/register', { 'name' => 'test', 'email' => 'test@example.com', 'password' => '1234567' }, @header

        expect(last_response.status).to eq(500)

        json_response = JSON.parse(last_response.body)

        expect(json_response['response']['errors']).to include('email is already taken')
      end
      
    end
    
    describe 'when password' do
      
      it 'is not present' do
        post '/api/register', { 'name' => 'test', 'email' => 'test@example.com' }, @header

        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response['response']['errors']).to include('password is not present')
      end
      
      it 'is too short' do
        post '/api/register', { 'name' => 'test', 'email' => 'test_example.com', 'password' => '123' }, @header
        
        expect(last_response.status).to eq(500)
  
        json_response = JSON.parse(last_response.body)

        expect(json_response['response']['errors']).to include('password is shorter than 6 characters')
      end
      
    end

  end
  
  describe 'is created' do
    before do
      DB[:permission_apps].delete
      DB[:access_tokens].delete
      DB[:users].delete
    end

    it 'when all fields are valid' do
      post '/api/register', { 'name' => 'test', 'email' => 'test@example.com', 'password' => '1234567' }, @header

      expect(last_response.status).to eq(200)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']).to include('access_token')
    end
    
  end
  
  describe 'does not enter in the system' do
    before do
      DB[:permission_apps].delete
      DB[:access_tokens].delete
      DB[:users].delete

      user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
    end
    
    it 'when email is wrong' do
      post '/api/login', { 'email' => 'test123@example.com', 'password' => '1234567' }, @header
      
      expect(last_response.status).to eq(500)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']['errors']).to include('email is not found')
    end
    
    it 'when email is nil' do
      post '/api/login', { 'password' => '1234567' }, @header
      
      expect(last_response.status).to eq(500)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']['errors']).to include('email is not found')
    end
    
    it 'when password does not match' do
      post '/api/login', { 'email' => 'test@example.com', 'password' => '12345678' }, @header
      
      expect(last_response.status).to eq(500)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']['errors']).to include('password is wrong')
    end
    
    it 'when password is nil' do
      post '/api/login', { 'email' => 'test@example.com'}, @header
      
      expect(last_response.status).to eq(500)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']['errors']).to include('password is wrong')
    end
    
  end
  
  describe 'enters in the system' do
    before do
      DB[:permission_apps].delete
      DB[:access_tokens].delete
      DB[:builds].delete
      DB[:android_apps].delete
      DB[:users].delete

      @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
    end
    
    it 'when email and password are right' do
      post '/api/login', { 'email' => 'test@example.com', 'password' => '1234567'}, @header
      
      expect(last_response.status).to eq(200)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']).to include('access_token')
    end
    
  end
  
  describe 'does not exit from the system' do
    
    before do
      DB[:permission_apps].delete
      DB[:access_tokens].delete
      DB[:builds].delete
      DB[:android_apps].delete
      DB[:users].delete

      @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
    end
    
    it 'when he has already exited' do
      post '/api/logout', {}, @header
    
      expect(last_response.status).to eq(401)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']['errors']).to include('user is unauthorized')
    end
    
  end
  
  describe 'does not exit from the system' do
    
    before do
      DB[:permission_apps].delete
      DB[:access_tokens].delete
      DB[:builds].delete
      DB[:android_apps].delete
      DB[:users].delete
      
      @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
    end
    
    it 'when he has already exited' do
      access_token = UserHelper.generate_access_token(@user.name, @user.email)
      @user.add_access_token(access_token: access_token)
      
      @header['HTTP_AUTHORIZATION'] = access_token
    
      AccessToken.where(access_token: access_token).delete
    
      post '/api/logout', {}, @header
    
      expect(last_response.status).to eq(401)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']['errors']).to include('user is unauthorized')
    end
    
  end
  
  describe 'exits from the system' do
    before do
      DB[:permission_apps].delete
      DB[:access_tokens].delete
      DB[:builds].delete
      DB[:android_apps].delete
      DB[:users].delete

      @user = User.create(name: 'Bob', email: 'test@example.com', password: '1234567')
    end
  
    it 'when he has already logged' do
      access_token = UserHelper.generate_access_token(@user.name, @user.email)
      @user.add_access_token(access_token: access_token)
      
      @header['HTTP_AUTHORIZATION'] = access_token
    
      post '/api/logout', {}, @header
  
      expect(last_response.status).to eq(200)

      json_response = JSON.parse(last_response.body)

      expect(json_response['response']['user_id']).to eq(@user.id)
    end
  end

end
