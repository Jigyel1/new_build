# frozen_string_literal: true

module Users
  class UserDeleter < BaseService
    include UserFinder

    def call
      user.discard!
    end
  end
end
