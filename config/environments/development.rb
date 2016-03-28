if CONFG[:debug?] == true
  ActiveRecord::Base.logger = Logger.new(STDOUT)
else
  ActiveRecord::Base.logger = Logger.new($logger)
end
