# frozen_string_literal: true

namespace :mailer do
  desc 'This is an idempotent execution. Can be called any number of times.'
  task test: :environment do
    AssigneeMailer.notify_on_assigned('31dfce73-c202-49b9-8fcf-5d5574a6d5cb', '20d75c62-4daf-47e5-a3fc-298d09f48b34').deliver_now
  end
end
