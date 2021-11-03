# frozen_string_literal: true

set :output, 'log/cron.log'

every 1.day, at: '9:00 am' do
  rake 'reminder:due_date_tomorrow'
end

every 1.day, at: '5:00 pm' do
  rake 'reminder:due_date_today'
end
