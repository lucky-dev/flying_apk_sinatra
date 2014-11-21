require 'spec_helper'

describe AndroidApp do
  before do
    @android_app = AndroidApp.new(name: "My cool app", description: "Cool app")
  end

  it "responds to methods" do
    expect(@android_app).to respond_to(:name)
    expect(@android_app).to respond_to(:description)
    expect(@android_app).to respond_to(:builds)
    expect(@android_app).to respond_to(:permission_apps)
    expect(@android_app).to respond_to(:add_build)
  end

  describe "is not valid" do
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
    
    it "when name is already taken" do
      DB[:builds].delete
      DB[:android_apps].delete

      app_with_same_name = @android_app.dup
      app_with_same_name.name = @android_app.name.upcase
      app_with_same_name.save

      expect(@android_app).not_to be_valid
    end
  end

  describe "is valid" do
    before do
      DB[:builds].delete
      DB[:android_apps].delete
    end

    it "when all properties are valid" do
      expect(@android_app).to be_valid
    end

    it "and has builds" do
      @android_app.save

      @build = Build.create(version: "1.0", fixes: "Some fixes")
      @android_app.add_build(@build)
      expect(@android_app.builds.size).to eq(1)
    end

    it "and has no builds" do
      @android_app.save

      expect(@android_app.builds.size).to eq(0)
    end
  end
end
