require 'sinatra/base'
require 'sinatra/config_file'
require 'sequel'
require 'yaml'

module FlyingApk
  class App < Sinatra::Base
    register Sinatra::ConfigFile

    config_file './config/flying_apk.yml'

    configure do
      if settings.production?
        name = settings.database['name']
        host = settings.database['host']
        user = settings.database['user']
        password = settings.database['password']

        DATABASE_URI = "mysql://#{user}:#{password}@#{host}/#{name}"
      else
        DATABASE_PATH = File.expand_path("./db/#{settings.database['name']}")
        DATABASE_URI = "sqlite://#{DATABASE_PATH}"
      end

      PASSWORD_SALT = settings.security['password_salt']

      PUBLIC_DIR = File.expand_path(settings.directories['public'])
      FILES_DIR = File.expand_path(settings.directories['apk_files'])

      Sequel.connect(DATABASE_URI)
      
      set :public_folder, PUBLIC_DIR

      # Get mail settings
      SMTP_SETTINGS = { address: settings.mail['smtp']['address'],
                        port: settings.mail['smtp']['port'],
                        user_name: settings.mail['smtp']['user_name'],
                        password: settings.mail['smtp']['password'],
                        authentication: settings.mail['smtp']['authentication'],
                        enable_starttls_auto: settings.mail['smtp']['enable_starttls_auto'],
                        tls: settings.mail['smtp']['tls'] }

      MAIL_SENDER = settings.mail['sender']
    end

    # Include all modules with models, helpers, routes and workers
    require_relative 'app/helpers/init.rb'
    require_relative 'app/models/init.rb'
    require_relative 'app/routes/init.rb'
    require_relative 'app/workers/init'

    # Include all routes
    use Routes::Users
    use Routes::AndroidApps
    use Routes::Builds
  end
end
