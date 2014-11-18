namespace :db do
  desc "Run migrations"

  # Helper methods
  def run_migration
    require_relative 'app'
    Sequel.extension :migration
    puts "Migrating to latest"
    Sequel::Migrator.run(Sequel.sqlite(FlyingApk::DATABASE_PATH), "db/migrations")
  end
  ###

  task :migrate do
    run_migration
  end

  task :delete_all do
    require_relative 'app'
    File.delete(FlyingApk::DATABASE_PATH)
  end

  namespace :migrate do
    task :test do
      ENV['RACK_ENV'] = 'test'
      run_migration
    end
  end

  namespace :delete_all do
    task :test do
      ENV['RACK_ENV'] = 'test'
      require_relative 'app'
      File.delete(FlyingApk::DATABASE_PATH)
    end
  end
end
