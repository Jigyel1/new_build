# frozen_string_literal: true

class ProjectMailer < ApplicationMailer
  def notify_building_count_error(external_ids, user_id)
    @external_ids = external_ids
    @user = User.find(user_id)

    notify(@user, 'notify_building_count_error')
  end

  def notify_assigned(assignee_type, assignee_id, project_id, current_user_id)
    @user = User.find(assignee_id)
    @current_user = User.find(current_user_id)
    @project = Project.find(project_id)

    notify(@user, "notify_#{assignee_type}_assigned")
  end

  def notify_project_assigned(assignee_id, project_name)
    @user = User.find(assignee_id)
    @project_name = project_name
    @project = Project.find_by(name: project_name)

    notify(@user, 'notify_project_assigned')
  end

  def notify_unassigned(assignee_type, assignee_id, assigner_id, project_id)
    @user = User.find(assignee_id)
    @assigner = User.find(assigner_id)
    @project = Project.find(project_id)

    notify(@user, "notify_#{assignee_type}_unassigned")
  end

  def notify_import(user_id, errors)
    @user = User.find(user_id)
    @errors = errors

    notify(@user, :notify_import)
  end

  private

  def notify(user, subject)
    mail(
      to: email_address_with_name(user.email, user.name),
      subject: I18n.t("mailer.project.#{subject}"),
      template_name: subject
    )
  end
end
