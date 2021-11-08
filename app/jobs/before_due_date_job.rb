# frozen_string_literal: true

class BeforeDueDateJob < ApplicationJob
  queue_as :before_due_date

  def perform
    binding.pry
    Projects::Task.connection.where(due_date: Date.tomorrow).group_by(&:assignee_id).each do |assignee_id, tasks|
      TaskMailer.notify_before_due_date(assignee_id, tasks).deliver
    end
  end
end
