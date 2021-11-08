# frozen_string_literal: true

require './config/boot'
require './config/environment'
require 'clockwork'

module Clockwork
  every(1.minute, 'Before due Date') do
    `rake reminder:due_date_tomorrow`
  end

  every(1.minute, 'on due Date') do
    `rake reminder:due_date_today`
  end
end
