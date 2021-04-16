# frozen_string_literal: true

module Users
  class UserUpdater < BaseService
    include UserFinder

    def call
      user.update!(attributes)
    end
  end
end
