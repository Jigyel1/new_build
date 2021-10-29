# frozen_string_literal: true

# set :output, "/path/to/my/cron_log.log"

every 1.day, at: '9:00 am' do
  echo 'you can use raw cron syntax too'
end

every 1.next_day, at: '5:00 pm' do
  echo 'you can use raw cron syntax too'
end
