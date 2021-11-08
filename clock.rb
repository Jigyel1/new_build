# frozen_string_literal: true

require './config/boot'
require './config/environment'
require 'clockwork'

module Clockwork
  every(1.minute, 'Before due Date') do
    BeforeDueDateJob.perform_now
  end

  every(1.minute, 'on due Date') do
    OnDueDateJob.perform_now
  end
end
