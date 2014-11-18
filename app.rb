require 'sinatra/base'
require 'sequel'
require 'find'

module FlyingApk
  DATABASE_PATH = "./db/flying_apk#{ENV['RACK_ENV'] == 'test' ? '_test' : '' }.db"

  class App < Sinatra::Base
    configure do
      Sequel.sqlite(DATABASE_PATH)

      # Include all models, helpers and routes
      Find.find("./app") do |path|
        require path if path =~ /\/(models|routes|helpers)\/.*\.rb$/
      end
    end

    use Routes::Users
  end
end
