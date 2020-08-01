# frozen_string_literal: true

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
    require './config/secret'
    require 'active_support/core_ext/integer/inflections'
    # Base API class then all the subclasses
    require './app/api/base'
    Dir['./app/api/*_api.rb'].sort.each { |f| require f }
    # transaction modules and classes
    require './app/models/transaction/shared'
    require './app/models/transaction'
    require './app/models/transaction/entry'
    require './app/models/transaction/entry_view'
    require './app/models/transaction/detail'
    require './app/models/transaction/detail_view'
    # budget module and classes
    require './app/models/budget/event_types'
    require './app/models/budget/shared'
    require './app/models/budget/category'
    require './app/models/budget/interval'
    require './app/models/budget/item'
    require './app/models/budget/category_maturity_interval'
    require './app/models/budget/item_view'
    require './app/models/budget/item_event_type'
    require './app/models/budget/item_event'
    require './app/models/budget/events/form_base'
    require './app/models/budget/events/create_item_form'
    Dir['./app/models/*.rb'].sort.each { |f| require f }
    Dir['./lib/*.rb'].sort.each { |f| require f }
  end
end
