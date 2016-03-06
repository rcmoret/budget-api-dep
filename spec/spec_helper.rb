ENV['RACK_ENV'] = 'test'
require 'rake'
Bundler.require(:test)
load ENV['PWD'] + '/Rakefile'
Rake::Task['app:setup'].invoke

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.warnings = true

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.profile_examples = 10

  # Kernel.srand config.seed
  # ActiveRecord::Base.connection
  FactoryGirl.definition_file_paths = %w{./spec/factories}
  FactoryGirl.find_definitions
end
