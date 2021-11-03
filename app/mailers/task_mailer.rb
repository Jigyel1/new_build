# frozen_string_literal: true

class TaskMailer < ApplicationMailer
  def notify_before_due_date(user_id, tasks)
    @user = User.find(user_id)
    @tasks = tasks

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: I18n.t('mailer.task.notify_before_due_date')
         )
  end

  def notify_on_due_date(user_id, tasks)
    @user = User.find(user_id)
    @tasks = tasks

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: I18n.t('mailer.task.notify_on_due_date')
    )
  end
end
