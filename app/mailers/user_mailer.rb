# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def invitation_instructions(record, token, opts = {})
    @token = token
    devise_mail(record, :invitation_instructions, opts)
  end
end
