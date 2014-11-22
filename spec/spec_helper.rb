require 'rack/test'
require 'rake'
require 'find'
require 'sequel'

ENV['RACK_ENV'] = 'test'

# Include all necessary files
# Include the file with entry point in the app
require File.expand_path('./app.rb')

# All constants
DB = Sequel.sqlite(FlyingApk::DATABASE_PATH)
MY_APP_FILE = File.expand_path("./spec/fixture/my_app.apk")

module RSpecMixin
  include Rack::Test::Methods

  def app
    FlyingApk::App
  end
end

# For RSpec 2.x
RSpec.configure do |conf|
  conf.include RSpecMixin
end
