require 'sinatra/base'
require 'sequel'
require 'find'
require 'json'

module FlyingApk
  DATABASE_PATH = File.expand_path("./db/flying_apk#{ENV['RACK_ENV'] == 'test' ? '_test' : '' }.db")
  FILES_DIR = File.expand_path("./public/files")

  class App < Sinatra::Base
    configure do
      set :public_folder, FILES_DIR
      
      Sequel.sqlite(DATABASE_PATH)

      # Include all models, helpers and routes      
      require_relative 'app/helpers/init.rb'
      require_relative 'app/models/init.rb'
      require_relative 'app/routes/init.rb'
    end

    use Routes::Users
    use Routes::AndroidApps
    use Routes::Builds
  end
end
