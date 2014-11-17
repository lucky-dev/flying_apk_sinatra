namespace :db do
  desc "Run migrations"

  def run_migration
    require_relative 'app'
    Sequel.extension :migration
    puts "Migrating to latest"
    Sequel::Migrator.run(Sequel.sqlite(FlyingApk::DATABASE_PATH), "db/migrations")
  end

  task :migrate do
    run_migration
  end
  
  namespace :migrate do
    task :test do
      ENV['RACK_ENV'] = 'test'
      run_migration
    end
  end

end
