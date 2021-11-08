# frozen_string_literal: true

require './config/boot'
require './config/environment'
require 'clockwork'

module Clockwork
  every(1.day, 'Before due Date', at: '9:00') do
    BeforeDueDateJob.perform_now
  end

  every(1.minute, 'on due Date', at: '17:00') do
    OnDueDateJob.perform_now
  end
end
