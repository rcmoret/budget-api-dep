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
    Dir.chdir(dir) do
      if `git diff origin/master`.empty?
        print_green 'no change'
      else
        print_green 'pushing the backup to bitbucket'
        `git add . && git commit --amend -m "update to dump (#{Time.now.strftime('%Y-%m-%d %H:%M')})" && git push -f`
      end
    end
  end
end
