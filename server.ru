# frozen_string_literal: true

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: %i[get post put options delete]
  end
end

map '/public' do
  run Root::Assets.new
end

map '/api/accounts' do
  run API::Accounts.new
end

map '/api/budget' do
  run API::Budget.new
end

map '/api/icons' do
  run API::Icons.new
end

map '/api/intervals' do
  run API::Intervals.new
end

map '/api/transfers' do
  run API::Transfers.new
end

map '/' do
  run Root::Index.new
end
