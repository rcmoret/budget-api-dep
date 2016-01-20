require 'bundler/setup'
Bundler.require(:development)
require './config/environments'
Dir['./app/*_api.rb'].each { |f| require f }
Dir['./app/models/*.rb'].each { |f| require f }
Dir['./app/templates/*.rb'].each { |f| require f }

map '/accounts' do
  run AccountsApi.new
end
