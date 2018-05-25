require 'date'
require_relative '../colorize'
include Colorize

namespace :backup do
  desc 'pushing the database backup'
  task :push do
    ENV['RACK_ENV'] ||= 'development'
    require 'bundler/setup'
    Bundler.require(:development)
    dir = "#{`pwd`.chomp}/db/dumps"
    file = "#{dir}/current.sql"
    if `diff #{file} #{dir}/previous.sql`.empty?
      print_green 'no change'
    else
      print_green 'pushing the backup to bitbucket'
      Dir.chdir(dir) do
        `git add . && git commit -m "update to dump (#{Time.now.strftime('%Y-%m-%d %H:%M')})" && git push`
      end
    end
  end
end
