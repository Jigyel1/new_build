# frozen_string_literal: true

module Users
  class UserUpdater < BaseService
    def call
      user.update!(attributes)
    end

    def user
      @user ||= User.find(attributes[:id])
    end
  end
end
