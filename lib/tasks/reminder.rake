# frozen_string_literal: true

namespace :reminder do
  desc 'Sends mail before the due date'
  task due_date_tomorrow: :environment do
    Projects::Task.where(due_date: Date.tomorrow).group_by(&:assignee_id).each do |assignee_id, tasks|
      TaskMailer.notify_before_due_date(assignee_id, tasks).deliver
    end
  end

  desc 'Sends mail on the due date'
  task due_date_today: :environment do
    Projects::Task.where(due_date: Date.current).group_by(&:assignee_id).each do |assignee_id, tasks|
      TaskMailer.notify_on_due_date(assignee_id, tasks).deliver
    end
  end
end
