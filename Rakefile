namespace :db do
  desc "Run migrations"

  namespace :migrate do
    def run_migration
      Sequel.extension :migration
      Sequel::Migrator.run(Sequel.connect(FlyingApk::App::DATABASE_URI), "db/migrations")
    end
    
    task :test do
      ENV['RACK_ENV'] = 'test'
      require_relative 'app'
      run_migration
    end

    task :development do
      ENV['RACK_ENV'] = 'development'
      require_relative 'app'
      run_migration
    end

    task :production do
      ENV['RACK_ENV'] = 'production'
      require_relative 'app'
      run_migration
    end
  end

  namespace :delete do
    task :test do
      ENV['RACK_ENV'] = 'test'
      require_relative 'app'
      File.delete(FlyingApk::App::DATABASE_PATH)
    end
    
    task :development do
      ENV['RACK_ENV'] = 'development'
      require_relative 'app'
      File.delete(FlyingApk::App::DATABASE_PATH)
    end
    
    task :production do
      ENV['RACK_ENV'] = 'production'
      require_relative 'app'
      DB = Sequel.connect(FlyingApk::App::DATABASE_URI)
      DB.run "DROP DATABASE flying_apk"
    end
  end
end

namespace :apk do
  require 'find'

  task :delete do
    Find.find('./public/files') do |path|
      if path =~ /.*\.apk$/
        File.delete(path)
        puts "#{path} is deleted"
      end
    end
  end
end
