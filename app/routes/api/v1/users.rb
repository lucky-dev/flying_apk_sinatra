module FlyingApk
  module Routes
    class Users < Sinatra::Base
      post '/api/register' do
        status, header, body = ApiV1::ApiHandler.handle(:register, request.env['HTTP_ACCEPT'], nil, params)
      end

      post '/api/login' do
        status, header, body = ApiV1::ApiHandler.handle(:login, request.env['HTTP_ACCEPT'], nil, params)
      end
    end
  end
end
