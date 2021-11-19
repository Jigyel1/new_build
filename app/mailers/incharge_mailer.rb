# frozen_string_literal: true

class InchargeMailer < ApplicationMailer
  def notify_on_incharge_assigned(user_id, project_id)
    notify(user_id, project_id, :incharge_assigned)
  end

  def notify_on_incharge_unassigned(user_id, project_id)
    notify(user_id, project_id, :incharge_unassigned)
  end

  private

  def notify(user_id, project_id, subject)
    @user = User.find(user_id)
    @project = Project.find(project_id)

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: I18n.t("mailer.#{subject}")
    )
  end
end
