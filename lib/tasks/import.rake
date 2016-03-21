require 'colorize'
include Colorize

namespace :pg do
  desc 'importing a database dump'
  task :import => :environment do
    file = if ENV['file']
             "#{Rails.root}/db/dumps/#{ENV['file']}"
           else
             "#{Rails.root}/db/dumps/current"
           end
    db_name = ActiveRecord::Base.connection.current_database
    command = "psql -d #{db_name} -f #{file}"
    print_green "Beginning database import from #{file} to #{db_name}"
    print_cyan  "EXECUTING: `#{command}'"
    `#{command}`
    print_green "COMPLETE"
  end
end
