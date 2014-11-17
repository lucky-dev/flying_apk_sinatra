require 'rack/test'
require 'find'

ENV['RACK_ENV'] = 'test'

# Include all necessary files
# Include the file with entry point in the app
require File.expand_path('./app.rb')

# Get app's dir
APP_DIR = File.dirname(File.expand_path('./app.rb'))

# Include all models and routes
Find.find("#{APP_DIR}/app") do |path|
  require path if path =~ /\/(models|routes)\/.*\.rb$/
end
###

module RSpecMixin
  include Rack::Test::Methods

  def app
    Flying::App
  end
end

# For RSpec 2.x
RSpec.configure do |conf|
  conf.include RSpecMixin
end
