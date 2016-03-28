db_config = CONFIG[:db_config]
ActiveRecord::Base.establish_connection(
  adapter: db_config['adapter'],
  database: db_config['database'],
  pool: db_config['pool']
)

