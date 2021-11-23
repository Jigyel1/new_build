# frozen_string_literal: true

namespace :mailer do
  desc 'This is an idempotent execution. Can be called any number of times.'
  task due_date_today: :environment do
    TaskMailer.notify_on_due_date('b71f5a96-ef93-4b93-bb95-04678c0d3015', Projects::Task.all).deliver_now
  end
end
