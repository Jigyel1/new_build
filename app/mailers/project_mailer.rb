# frozen_string_literal: true

class ProjectMailer < ApplicationMailer
  def notify_on_assigned(user_id, project_id)
    notify(user_id, project_id, nil, nil, :assignee_assigned)
  end

  def notify_on_unassigned(user_id, current_user_id, project_id)
    notify(user_id, project_id, current_user_id, nil, :assignee_unassigned)
  end

  def notify_on_incharge_assigned(user_id, project_id)
    notify(user_id, project_id, nil, nil, :incharge_assigned)
  end

  def notify_on_incharge_unassigned(user_id, project_id, current_user_id)
    notify(user_id, project_id, current_user_id, nil, :incharge_unassigned)
  end

  def notify_import(user_id, errors)
    notify(user_id, nil, nil, errors, :project_import)
  end

  private

  def notify(user_id, project_id, current_user_id, errors, subject)
    @user = User.find(user_id)
    @current_user = User.find(current_user_id) if current_user_id.present?
    @project = Project.find(project_id) if project_id.present?
    @errors = errors if errors.present?

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: I18n.t("mailer.#{subject}")
    )
  end
end
