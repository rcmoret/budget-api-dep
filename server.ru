# frozen_string_literal: true

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: %i[get post put options delete]
  end
end

map '/accounts' do
  run API::Accounts.new
end

map '/budget' do
  run API::Budget.new
end

map '/icons' do
  run API::Icons.new
end

map '/intervals' do
  run API::Intervals.new
end

map '/transfers' do
  run API::Transfers.new
end
