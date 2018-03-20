require_relative '../colorize'
include Colorize

namespace :pg do
  desc 'dumping the database'
  task :dump do
    ENV['RACK_ENV'] ||= 'development'
    require 'bundler/setup'
    Bundler.require(:development)
    require './config/environments'
    dir = "#{`pwd`.chomp}/db/dumps"
    date = Date.today.strftime('%Y_%m_%d')
    file_name = if ENV['file_name']
                  "#{ENV['file_name']}.sql"
                elsif ENV['RACK_ENV'] == 'development'
                  "#{date}-dump.sql"
                else
                  "#{date}-#{ENV['RACK_ENV']}-dump.sql"
                end
    file = "#{dir}/#{file_name}"
    db_name = ActiveRecord::Base.connection.current_database
    command = "pg_dump -a -O --exclude-table=schema_migrations -f #{file} #{db_name}"
    print_green "Beginning database dump from #{db_name} to #{file}"
    print_cyan  "EXECUTING: `#{command}'"
    `#{command}`
    print_green "Linking #{file_name} to `current'"
    `ln -sfn #{file} #{dir}/current`
    print_green "COMPLETE"
  end
end
