require 'sinatra/base'
require 'sequel'

module FlyingApk
  DATABASE_PATH = "./db/flying_apk#{ENV['RACK_ENV'] == 'test' ? '_test' : '' }.db"

  class App < Sinatra::Base
    configure do
      Sequel.sqlite(DATABASE_PATH)
    end
  end
end
