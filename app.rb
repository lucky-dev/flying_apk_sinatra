require 'sinatra/base'
require 'sequel'
require 'find'
require 'json'

module FlyingApk
  DATABASE_PATH = "./db/flying_apk#{ENV['RACK_ENV'] == 'test' ? '_test' : '' }.db"
  FILES_DIR = File.expand_path("./public/files")

  class App < Sinatra::Base
    configure do
      set :public_folder, FILES_DIR
      
      Sequel.sqlite(DATABASE_PATH)

      # Include all models, helpers and routes
      Find.find("./app") do |path|
        require path if path =~ /\/(models|routes|helpers)\/.*\.rb$/
      end
    end

    use Routes::Users
    use Routes::AndroidApps
    use Routes::Builds
  end
end
