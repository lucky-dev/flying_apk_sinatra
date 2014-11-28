require 'spec_helper'

describe Build do
  before do
    @build = Build.new(version: "1.0", fixes: "Some fixes", created_time: Time.now.utc, file_name: "my_app.apk", file_checksum: "ea6e9d41130509444421709610432ee1")
  end

  it "responds to methods" do
    expect(@build).to respond_to(:version)
    expect(@build).to respond_to(:fixes)
    expect(@build).to respond_to(:created_time)
    expect(@build).to respond_to(:file_name)
    expect(@build).to respond_to(:file_checksum)
    expect(@build).to respond_to(:android_app)
  end

  describe "is not valid" do
    it "when version is not present" do
      @build.version = "   "
      expect(@build).not_to be_valid
    end

    it "when fixes is not present" do
      @build.fixes = "   "
      expect(@build).not_to be_valid
    end

    it "when version is too long" do
      @build.version = "x" * 11
      expect(@build).not_to be_valid
    end

    it "when fixes is too short" do
      @build.fixes = "y" * 141
      expect(@build).not_to be_valid
    end
  end

  describe "is valid" do
    it "when all properties are valid" do
      expect(@build).to be_valid
    end
  end

end
