configure do
  db_config = YAML.load(File.open('./config/database.yml'))[ENV['RACK_ENV']]
  ActiveRecord::Base.establish_connection(
    adapter: db_config['adapter'],
    database: db_config['database'],
    pool: db_config['pool']
  )
end
