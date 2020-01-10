ActiveRecord::Base.logger = # frozen_string_literal: true
  if CONFIG[:debug?] == true
    Logger.new(STDOUT)
  else
    Logger.new($logger)
                              end
