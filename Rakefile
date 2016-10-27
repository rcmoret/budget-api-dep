require 'rake'
require 'standalone_migrations'
require './lib/colorize'
Dir.glob('lib/tasks/*.rake').each { |r| load r }

task :default => 'app:start'
task :console => 'app:console'
task :server  => 'app:start'

StandaloneMigrations::Tasks.load_tasks

namespace :app do
  desc 'Start application in development'
  task :start => :setup do
    Rack::Server.start(config: './server.ru', Host: '0.0.0.0')
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
    require 'action_view'
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
