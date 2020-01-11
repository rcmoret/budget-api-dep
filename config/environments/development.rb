# frozen_string_literal: true

ActiveRecord::Base.logger =
  if CONFIG[:debug?] == true
    Logger.new(STDOUT)
  else
    Logger.new($logger)
  end
