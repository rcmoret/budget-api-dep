ENV['RACK_ENV'] = 'test'
require 'rake'
require 'database_cleaner'
Bundler.require(:test)
load ENV['PWD'] + '/Rakefile'
require './spec/helpers/custom_matchers'
Rake::Task['app:setup'].invoke


RSpec.configure do |config|
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
  config.include(Shoulda::Matchers::Independent)

  config.include(Helpers::CustomMatchers)
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  # config.profile_examples = 10

  # Kernel.srand config.seed
  # ActiveRecord::Base.connection
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
