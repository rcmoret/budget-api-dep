configure :development do
  db_config = YAML.load(File.open('./config/database.yml'))['development']
  ActiveRecord::Base.establish_connection(
    adapter: db_config['adapter'],
    database: db_config['database'],
    pool: db_config['pool']
  )
end

configure :test do
  db_config = YAML.load(File.open('./config/database.yml'))['test']
  ActiveRecord::Base.establish_connection(
    adapter: db_config['adapter'],
    database: db_config['database'],
    pool: db_config['pool']
  )
end
