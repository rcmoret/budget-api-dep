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
    if `git diff origin/master`.empty?
      print_green 'no change'
    else
      print_green 'pushing the backup to bitbucket'
      Dir.chdir(dir) do
        `git add . && git commit --amend && git push -f`
      end
    end
  end
end
