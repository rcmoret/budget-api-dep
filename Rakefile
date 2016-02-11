require 'rake'

task :default => 'app:start'
task :console => 'app:console'

namespace :app do
  desc 'Start application in development'
  task :start do
    exec 'rackup -o 0.0.0.0'
  end
  desc 'Start application console'
  task :console do
    require 'irb'
    require 'irb/completion'
    require 'bundler/setup'
    Bundler.require(:development)
    require './config/environments'
    Dir['./app/*_api.rb'].each { |f| require f }
    Dir['./app/models/*.rb'].each { |f| require f }
    Dir['./app/templates/*.rb'].each { |f| require f }
    ARGV.clear
    IRB.start
  end
end
