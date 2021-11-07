# frozen_string_literal: true

require 'clockwork'
require 'active_support/time'

module Clockwork
  every(1.day, 'Before due Date', at: '09:00') do
    `rake reminder:due_date_tomorrow`
  end

  every(1.day, 'on due Date', at: '17:00') do
    `rake reminder:due_date_today`
  end
end
