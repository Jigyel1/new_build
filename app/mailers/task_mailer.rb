# frozen_string_literal: true

class TaskMailer < ApplicationMailer
  def notify_before_due_date(user_id, task_id)
    user = User.find(user_id)
    @task = Projects::Task.find(task_id)

    mail(to: email_address_with_name(user.email, user.name))
  end

  def notify_on_due_date(user_id, task_id)
    user = User.find(user_id)
    @task = Projects::Task.find(task_id)

    mail(to: email_address_with_name(user.email, user.name))
  end
end
