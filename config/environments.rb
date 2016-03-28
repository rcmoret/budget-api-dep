configure do
  CONFIG = { db_config: YAML.load(File.open('./config/database.yml'))[ENV['RACK_ENV']] }
  load "./config/initializers/database.rb"
  load "./config/environments/#{ENV['RACK_ENV']}.rb"
  enable :logging
  $logger = Logger.new("./log/sinatra.log")
end
