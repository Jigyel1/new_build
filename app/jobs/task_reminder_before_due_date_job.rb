# frozen_string_literal: true

class TaskReminderBeforeDueDateJob < ApplicationJob
  queue_as :before_due_date

  def perform(user_id)
    user = User.find(user_id)
    TaskMailer.notify_before_due_date(user)
  end
end
