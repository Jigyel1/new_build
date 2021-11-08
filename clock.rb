# frozen_string_literal: true

require './config/boot'
require './config/environment'
require 'clockwork'

module Clockwork
  every(1.minute, 'Before due Date') do
    ::Projects::Reminders::DueDateTomorrow.call
  end

  every(1.minute, 'on due Date') do
    ::Projects::Reminders::DueDateToday.call
  end
end
