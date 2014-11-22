module FlyingApk
  module Routes
    class Builds < Sinatra::Base
      post '/builds' do
        status, header, body = ApiV1::ApiHandler.handle(:create_build, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
      
      get '/builds' do
        status, header, body = ApiV1::ApiHandler.handle(:get_builds, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
      
      put '/builds/:id' do
        status, header, body = ApiV1::ApiHandler.handle(:update_build, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
      
      delete '/builds/:id' do
        status, header, body = ApiV1::ApiHandler.handle(:delete_build, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
    end
  end
end
