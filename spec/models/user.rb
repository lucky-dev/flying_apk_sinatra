require 'spec_helper'

describe User do
  before do
    @user = User.new(name: "Bob", email: "test@example.com", password: "1234567")
  end

  it "responds to methods" do
    expect(@user).to respond_to(:name)
    expect(@user).to respond_to(:email)
    expect(@user).to respond_to(:password)
    expect(@user).to respond_to(:access_token)
  end

  describe "when user is not valid" do
    it "when name is not present" do
      @user.name = "   "
      expect(@user).not_to be_valid
    end
    it "when email is not present" do
      @user.email = "   "
      expect(@user).not_to be_valid
    end
    it "when password is not present" do
      @user.password = "   "
      expect(@user).not_to be_valid
    end
    it "when name is too long" do
      @user.name = "x" * 50
      expect(@user).not_to be_valid
    end
    it "when password is too short" do
      @user.password = "123"
      expect(@user).not_to be_valid
    end
    it "when email format is invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when android app is valid" do
    it "when all properties are valid" do
      expect(@android_app).to be_valid
    end
    
    it "when email format is valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        expect(@user).to be_valid
      end
    end
  end
end
