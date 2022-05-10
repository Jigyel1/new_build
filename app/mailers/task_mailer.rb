# frozen_string_literal: true

class TaskMailer < ApplicationMailer
  def notify_created(user_id, task_id, project_id)
    notify(user_id, nil, task_id, project_id, :task_created)
  end

  def notify_before_due_date(user_id, tasks)
    notify(user_id, tasks, nil, nil, :notify_before_due_date)
  end

  def notify_on_due_date(user_id, tasks)
    notify(user_id, tasks, nil, nil, :notify_on_due_date)
  end

  private

  def notify(user_id, tasks, task_id, project_id, subject)
    @user = User.find(user_id)
    @tasks = tasks
    @task = Projects::Task.find(task_id) if task_id.present?
    @project = Project.find(project_id) if project_id.present?

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: I18n.t("mailer.task.#{subject}")
    )
  end
end
