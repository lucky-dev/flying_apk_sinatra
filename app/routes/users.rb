require './app/helpers/api_helper.rb'
require './app/helpers/api/v1/api.rb'

module FlyingApk
  module Routes
    class Users < Sinatra::Base
      post '/register' do
        if ApiHelper.get_api_version(request.env['HTTP_ACCEPT']) == 1
          status, headers, body = ApiV1::ApiHandler.register(params[:email], params[:password])
        end
      end

      post '/login' do
      end
    end
  end
end
