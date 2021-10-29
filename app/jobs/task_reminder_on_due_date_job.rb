# frozen_string_literal: true

class TaskReminderOnDueDateJob < ApplicationJob
  queue_as :on_due_date

  def perform(user_id)
    user = User.find(user_id)
    TaskMailer.notify_on_due_date(user)
  end
end
