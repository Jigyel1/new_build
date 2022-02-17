# frozen_string_literal: true

class PenetrationMailer < ApplicationMailer
  def notify_import(user_id, errors)
    @user = User.find(user_id)
    @errors = errors

    mail(
      to: email_address_with_name(@user.email, @user.name),
      subject: I18n.t('mailer.penetration.notify_import')
    )
  end
end
