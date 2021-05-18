# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  before_action :inline_logo

  def inline_logo
    attachments.inline['logo.png'] = File.read(Rails.root.join('app/assets/images/upc-logo.png'))
  end
end
