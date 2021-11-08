# frozen_string_literal: true

require './config/boot'
require './config/environment'
require 'clockwork'
Rails.application.load_tasks

module Clockwork
  every(1.minute, 'Before due Date') do
    Rake::Task['reminder:due_date_tomorrow'].invoke
  end

  every(1.minute, 'on due Date') do
    Rake::Task['reminder:due_date_today'].invoke
  end
end
