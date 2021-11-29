# frozen_string_literal: true

class TaskMailer < ApplicationMailer
  def notify_created(user_id, task)
    notify(user_id, task, :assignee_assigned)
  end

  def notify_before_due_date(user_id, tasks)
    notify(user_id, tasks, :notify_before_due_date)
  end

  def notify_on_due_date(user_id, tasks)
    notify(user_id, tasks, :notify_on_due_date)
  end

  private

  def notify(user_id, tasks, subject)
    @user = User.find(user_id)
    @tasks = tasks

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: I18n.t("mailer.task.#{subject}")
    )
  end
end
