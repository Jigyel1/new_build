# frozen_string_literal: true

module Users
  class UserCreator < BaseService
    attr_accessor :user, :auth

    def call
      @user = User.find_by(email: auth.dig(:info, :email))
      user.present? ? update : add_error
      user
    end

    private

    def update
      user.password = Devise.friendly_token[0, 20]
      user.uid = auth[:uid]
      user.provider = auth[:provider]
      user.save
    end

    def add_error
      @user = User.new(email: auth.dig(:info, :email))
      user.errors.add(:base, I18n.t('devise.sign_in.not_found'))
    end
  end
end
