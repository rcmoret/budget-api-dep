require 'rake'
require './lib/colorize'
require 'standalone_migrations'
require 'yaml'

Dir.glob('lib/tasks/*.rake').each { |r| load r }

task default: 'app:start'
task console: 'app:console'
task server: 'app:start'

StandaloneMigrations::Tasks.load_tasks

namespace :app do
  desc 'Start application in development'
  task start: :setup do
    Rack::Server.start(Settings::SERVER_SETTINGS.dup)
  end
  desc 'Start application console'
  task console: :setup do
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
    require './config/settings'
    require './config/environments'
    Dir['./app/*.rb'].each { |f| require f }
    Dir['./app/helpers/*_helpers.rb'].each { |f| require f }
    Dir['./app/api/*.rb'].each { |f| require f }
    Dir['./app/concerns/*.rb'].each { |f| require f }
    # transaction modules and classes
    require './app/models/transaction/shared'
    require './app/models/transaction/view'
    require './app/models/transaction/record'
    require './app/models/transaction/sub_transaction'
    require './app/models/transaction/primary_transaction'
    # budget module and classes
    require './app/models/budget/shared'
    require './app/models/budget/category'
    require './app/models/budget/interval'
    require './app/models/budget/item'
    require './app/models/budget/category_maturity_interval'
    require './app/models/budget/item_view'
    Dir['./app/models/*.rb'].each { |f| require f }
    Dir['./app/templates/*.rb'].each { |f| require f }
    Dir['./lib/*.rb'].each { |f| require f }
    Dir['./lib/templates/*.rb'].each { |f| require f }
  end
end
