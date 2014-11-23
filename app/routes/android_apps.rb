module FlyingApk
  module Routes
    class AndroidApps < Sinatra::Base
      post '/android_apps' do
        status, header, body = ApiV1::ApiHandler.handle(:create_android_app, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
      
      get '/android_apps' do
        status, header, body = ApiV1::ApiHandler.handle(:get_android_apps, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
      
      put '/android_apps/:id' do
        status, header, body = ApiV1::ApiHandler.handle(:update_android_app, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
      
      delete '/android_apps/:id' do
        status, header, body = ApiV1::ApiHandler.handle(:delete_android_app, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
      
      post '/android_apps/:id/add_user' do
        status, header, body = ApiV1::ApiHandler.handle(:add_user_to_app, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
      
      post '/android_apps/:id/remove_user' do
        status, header, body = ApiV1::ApiHandler.handle(:remove_user_from_app, request.env['HTTP_ACCEPT'], request.env['HTTP_AUTHORIZATION'], params)
      end
    end
  end
end
