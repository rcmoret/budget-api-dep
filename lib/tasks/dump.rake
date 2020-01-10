# frozen_string_literal: true

require_relative '../colorize'
include Colorize

namespace :pg do
  desc 'dumping the database'
  task :dump do
    ENV['RACK_ENV'] = 'development'
    require 'bundler/setup'
    Bundler.require(:development)
    require './config/environments'
    dir = "#{`pwd`.chomp}/db/dumps"
    file = "#{dir}/current.sql"
    db_name = ActiveRecord::Base.connection.current_database
    abort unless db_name == 'checkbook_new'
    command = "pg_dump -a -O --exclude-table=schema_migrations -f #{file} #{db_name}"
    print_green "Beginning database dump from #{db_name} to #{file}"
    print_cyan  "EXECUTING: `#{command}'"
    `#{command}`
    print_green 'COMPLETE'
  end
end
