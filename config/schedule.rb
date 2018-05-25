every 1.day, at: ['08:00am', '11:00am', '05:00pm', '10:00pm'] do
  rake 'pg:dump'
  rake 'backup:push'
end
