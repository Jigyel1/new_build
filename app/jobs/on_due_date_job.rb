# frozen_string_literal: true

class OnDueDateJob < ApplicationJob
  queue_as :on_due_date

  def perform
    Projects::Task.connection.where(due_date: Date.current).group_by(&:assignee_id).each do |assignee_id, tasks|
      TaskMailer.notify_on_due_date(assignee_id, tasks).deliver
    end
  end
end
