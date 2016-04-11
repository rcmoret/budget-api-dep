require 'sass/plugin/rack'

use Rack::Cors do
  allow do
    origins '*'
    resource '*'
  end
end


use Sass::Plugin::Rack

map '/' do
  run Index.new
end

map '/items' do
  run ItemsApi.new
end

map '/accounts' do
  run AccountsApi.new
end
