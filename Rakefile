require 'rake'

desc 'Start application in development'
task :default => 'app:start'

namespace :app do
  task :start do
    exec 'ruby app/budget_api.rb -o 0.0.0.0'
  end
end
