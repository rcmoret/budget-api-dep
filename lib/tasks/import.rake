# frozen_string_literal: true

require_relative '../colorize'

namespace :pg do
  desc 'importing a database dump'
  task :import do
    include Colorize
    ENV['RACK_ENV'] ||= 'development'
    require 'bundler/setup'
    Bundler.require(:development)
    require './config/environments'
    file = if ENV['file']
             "#{`pwd`.chomp}/db/dumps/#{ENV['file']}"
           else
             "#{`pwd`.chomp}/db/dumps/current.sql"
           end
    db_name = ActiveRecord::Base.connection.current_database
    command = "psql -d #{db_name} -f #{file}"
    print_green "Beginning database import from #{file} to #{db_name}"
    print_cyan  "EXECUTING: `#{command}'"
    `#{command}`
    print_green 'COMPLETE'
  end
end
