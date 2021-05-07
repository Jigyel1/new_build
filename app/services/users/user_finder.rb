# frozen_string_literal: true

module Users
  module UserFinder
    def user
      @user ||= User.find(attributes[:id])
    end
  end
end
