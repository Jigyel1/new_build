# frozen_string_literal: true

module Users
  class UserCreator < BaseService
    attr_accessor :user, :auth

    # `email` lookup if the user is logging in for the first time.
    # `uid` lookup will be relevant if user has updated his email in azure.
    def call # rubocop:disable  Metrics/AbcSize
      Rails.logger.info(log_values)
      @user = User.find_by(email: auth.dig(:info, :email).try(:downcase)) || User.find_by(uid: auth[:uid])
      user.present? ? update : add_error
      Rails.logger.info(user.errors.full_messages)
      user
    end

    private

    def update
      user.assign_attributes(
        uid: auth[:uid],
        email: auth.dig(:info, :email),
        provider: auth[:provider],
        password: Devise.friendly_token[0, 20]
      )
      user.save
    end

    def add_error
      @user = User.new(email: auth.dig(:info, :email))
      user.errors.add(:base, I18n.t('devise.sign_in.not_found'))
    end

    def log_values
      {
        email: auth.dig(:info, :email),
        info: auth[:info],
        provider: auth[:provider],
        provider_s: auth['provider'],
        uid: auth[:uid],
        uid_s: auth['uid']
      }
    end
  end
end
