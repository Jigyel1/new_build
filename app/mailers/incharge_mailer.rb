# frozen_string_literal: true

class InchargeMailer < ApplicationMailer
  def notify_on_incharge_assigned(user_id, project_id)
    notify(user_id, project_id, nil, :incharge_assigned)
  end

  def notify_on_incharge_unassigned(user_id, project_id, current_user_id)
    notify(user_id, project_id, current_user_id, :incharge_unassigned)
  end

  private

  def notify(user_id, project_id, current_user_id, subject)
    @user = User.find(user_id)
    @current_user = User.find(current_user_id) if current_user_id.present?
    @project = Project.find(project_id)

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: I18n.t("mailer.#{subject}")
    )
  end
end
