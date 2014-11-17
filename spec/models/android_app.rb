require 'spec_helper'

describe AndroidApp do
  before do
    @android_app = AndroidApp.new(name: "My cool app", description: "Cool app")
  end

  it "responds to methods" do
    expect(@android_app).to respond_to(:name)
    expect(@android_app).to respond_to(:description)
  end
  
  describe "when android app is not valid" do
    it "when name is not present" do
      @android_app.name = "   "
      expect(@android_app).not_to be_valid
    end
    it "when description is not present" do
      @android_app.description = "   "
      expect(@android_app).not_to be_valid
    end
    it "when name is too long" do
      @android_app.name = "x" * 51
      expect(@android_app).not_to be_valid
    end
    it "when description is too long" do
      @android_app.description = "y" * 141
      expect(@android_app).not_to be_valid
    end
  end

  describe "when android app is valid" do
    it "when all properties are valid" do
      expect(@android_app).to be_valid
    end
  end
end
