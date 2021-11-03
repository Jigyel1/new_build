# frozen_string_literal: true

namespace :reminder do
  desc 'This is called before due date'
  task due_date_tomorrow: :environment do
    before_due_date = Projects::Task.where(due_date: Date.tomorrow).group_by(&:assignee_id)
    before_due_date.each { |assignee_id, tasks| TaskMailer.notify_before_due_date(assignee_id, tasks).deliver }
  end

  desc 'This is called on due date'
  task due_date_today: :environment do
    on_due_date = Projects::Task.where(due_date: Date.current).group_by(&:assignee_id)
    on_due_date.each { |assignee_id, tasks| TaskMailer.notify_on_due_date(assignee_id, tasks).deliver }
  end
end
