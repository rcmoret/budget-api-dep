# frozen_string_literal: true

every 1.day, at: ['10:00am', '1:00pm', '05:00pm', '10:00pm'] do
  rake 'pg:dump'
  rake 'backup:push'
end
