ENV['RACK_ENV'] = 'test'
require 'rake'
require 'database_cleaner'
Bundler.require(:test)
load ENV['PWD'] + '/Rakefile'
Rake::Task['app:setup'].invoke
Dir['./spec/helpers/*.rb'].each { |f| require f }
Dir['./spec/shared/*_examples.rb'].each { |f| require f }

RSpec.configure do |config|
  config.include(Helpers::CustomMatchers)
  config.include(Helpers::RequestHelpers)
  config.include(Rack::Test::Methods)
  config.include(SharedExamples::TransactionExamples)
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

  FactoryBot.definition_file_paths = %w{./spec/factories}
  FactoryBot.find_definitions
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
    '/accounts' => AccountsApi.new,
    '/budget' => BudgetApi.new,
    '/icons' => IconsApi.new,
    '/transfers' => TransfersApi.new,
  )
end
