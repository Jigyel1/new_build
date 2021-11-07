# frozen_string_literal: true

require 'clockwork'
require 'active_support/time'

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  every(1.minute, 'Before due Date') do
    rake 'reminder:due_date_tomorrow'
  end

  # every(1.minute, 'on due Date') do
  #   `rake reminder:due_date_today`
  # end
end
