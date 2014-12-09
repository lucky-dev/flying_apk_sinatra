require 'sinatra/base'
require 'sequel'
require 'yaml'

module FlyingApk
  class App < Sinatra::Base
    SETTINGS = YAML.load_file("config.yml")
    
    configure :test do
      DATABASE_PATH = File.expand_path("./db/#{SETTINGS["database"]["test"]["name"]}")
      DATABASE_URI = "sqlite://#{DATABASE_PATH}"
      PASSWORD_SALT = SETTINGS["security"]["test"]["password_salt"]
    end

    configure :development do
      DATABASE_PATH = File.expand_path("./db/#{SETTINGS["database"]["development"]["name"]}")
      DATABASE_URI = "sqlite://#{DATABASE_PATH}"
      PASSWORD_SALT = SETTINGS["security"]["development"]["password_salt"]
    end
    
    configure :production do
      name = SETTINGS["database"]["production"]["name"]
      host = SETTINGS["database"]["production"]["host"]
      user = SETTINGS["database"]["production"]["user"]
      password = SETTINGS["database"]["production"]["password"]

      DATABASE_URI = "mysql://#{user}:#{password}@#{host}/#{name}"
      PASSWORD_SALT = SETTINGS["security"]["production"]["password_salt"]
    end

    configure do
      PUBLIC_DIR = File.expand_path(SETTINGS["directories"]["public"])
      FILES_DIR = File.expand_path(SETTINGS["directories"]["apk_files"])
      
      Sequel.connect(DATABASE_URI)
      
      set :public_folder, PUBLIC_DIR

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
