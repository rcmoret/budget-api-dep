# frozen_string_literal: true

configure do
  CONFIG = { db_config: YAML.safe_load(File.open('./config/database.yml'))[ENV['RACK_ENV']] }.freeze
  load './config/initializers/database.rb'
  load "./config/environments/#{ENV['RACK_ENV']}.rb"
  enable :logging
  $logger = Logger.new('./log/sinatra.log')
end
