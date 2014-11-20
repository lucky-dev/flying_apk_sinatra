module FlyingApk
  module Routes
    class Users < Sinatra::Base
      post '/register' do
        status, header, body = ApiV1::ApiHandler.handle(:register, request.env['HTTP_ACCEPT'], params)
      end

      post '/login' do
      end
    end
  end
end
