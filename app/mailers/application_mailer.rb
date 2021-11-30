# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.mail_sender
  layout 'mailer'

  before_action :inline_logo

  private

  def inline_logo
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/upc-logo.png'))
  end
end
