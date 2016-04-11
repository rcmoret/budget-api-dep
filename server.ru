require 'sass/plugin/rack'

use Rack::Cors do
  allow do
    origins '*'
    resource '*'
  end
end

map '/items' do
  run ItemsApi.new
end

map '/accounts' do
  run AccountsApi.new
end
