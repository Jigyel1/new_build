# frozen_string_literal: true

module Devise
  class CustomFailureApp < ::Devise::FailureApp
    # We need to be able to differentiate if the failure is because of the invalid
    # token issue, or if it is because user can login through azure, but hasn't been
    # invited to the portal. For the former we return a status code 401 and 403 for the latter.
    def respond
      self.status = i18n_message == I18n.t('devise.sign_in.not_found') ? 403 : 401
      self.content_type = 'json'
      self.response_body = { errors: [i18n_message] }.to_json
    end
  end
end
