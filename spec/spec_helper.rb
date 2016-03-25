ENV['RACK_ENV'] = 'test'
require 'rake'
require 'database_cleaner'
Bundler.require(:test)
load ENV['PWD'] + '/Rakefile'
require './spec/helpers/custom_matchers'
Rake::Task['app:setup'].invoke

RSpec.configure do |config|
  config.include(Helpers::CustomMatchers)
  config.include(Rack::Test::Methods)
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
  config.include(Shoulda::Matchers::Independent)

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  FactoryGirl.definition_file_paths = %w{./spec/factories}
  FactoryGirl.find_definitions
  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
  config.around(:each) do |example|
    DatabaseCleaner.cleaning { example.run }
  end
end

def app
  Rack::URLMap.new(
    '/accounts' => AccountsApi.new
  )
end
