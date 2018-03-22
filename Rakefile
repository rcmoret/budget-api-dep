require 'rake'
require './lib/colorize'
require 'active_record'
require 'yaml'
Dir.glob('lib/tasks/*.rake').each { |r| load r }

task :default => 'app:start'
task :console => 'app:console'
task :server  => 'app:start'

namespace :app do
  desc 'Start application in development'
  task :start => :setup do
    Rack::Server.start(config: './server.ru', Host: '0.0.0.0', Port: 8080)
  end
  desc 'Start application console'
  task :console => :setup do
    require 'irb'
    require 'irb/completion'
    ARGV.clear
    IRB.start
  end
  desc 'require all gems, app files, configs'
  task :setup do
    ENV['RACK_ENV'] ||= 'development'
    require 'bundler/setup'
    Bundler.require(:development)
    Bundler.require(:assets)
    require './config/environments'
    Dir['./app/*.rb'].each { |f| require f }
    Dir['./app/helpers/*_helpers.rb'].each { |f| require f }
    Dir['./app/api/*.rb'].each { |f| require f }
    Dir['./app/concerns/*.rb'].each { |f| require f }
    Dir['./app/models/*.rb'].each { |f| require f }
    Dir['./app/templates/*.rb'].each { |f| require f }
    Dir['./lib/*.rb'].each { |f| require f }
  end
end

namespace :db do
  ENV['RACK_ENV'] ||= 'development'
  db_config       = YAML::load(File.open('config/database.yml'))[ENV['RACK_ENV']]
  db_config_admin = db_config.merge({'database' => 'postgres', 'schema_search_path' => 'public'})

  desc "Create the database"
  task :create do
    ActiveRecord::Base.establish_connection(db_config_admin)
    ActiveRecord::Base.connection.create_database(db_config["database"])
    puts "Database created."
  end

  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Migrator.migrate("db/migrate/")
    Rake::Task["db:schema"].invoke
    puts "Database migrated."
  end

  desc "Drop the database"
  task :drop do
    ActiveRecord::Base.establish_connection(db_config)
    ActiveRecord::Base.connection.drop_database(db_config["database"])
    puts "Database deleted."
  end

  desc "Reset the database"
  task :reset => [:drop, :create, :migrate]

  desc 'Create a db/schema.rb file that is portable against any DB supported by AR'
  task :schema do
    ActiveRecord::Base.establish_connection(db_config)
    require 'active_record/schema_dumper'
    filename = "db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end
end

namespace :g do
  desc "Generate migration"
    task :migration do
      name = ARGV[1] || raise("Specify name: rake g:migration your_migration")
      timestamp = Time.now.strftime("%Y%m%d%H%M%S")
      path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
      migration_class = name.split("_").map(&:capitalize).join

      File.open(path, 'w') do |file|
        file.write <<-EOF
        class #{migration_class} < ActiveRecord::Migration
          def self.up
          end

          def self.down
          end

          end
        EOF
      end

      puts "Migration #{path} created"
      abort # needed stop other tasks
    end
end
