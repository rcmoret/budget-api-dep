require 'sass/plugin/rack'

use Rack::Cors do
  allow do
    origins '*'
    resource '*'
  end
end


use Sass::Plugin::Rack

map '/budget' do
  run BudgetApi.new
end

map '/accounts' do
  run AccountsApi.new
end
