# frozen_string_literal: true

class ProjectMailer < ApplicationMailer
  def notify_import(user, errors)
    @errors = errors
    @user = user

    mail(to: email_address_with_name(user.email, user.name))
  end
end
