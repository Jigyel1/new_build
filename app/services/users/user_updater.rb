# frozen_string_literal: true

module Users
  class UserUpdater < BaseService
    include UserFinder

    def call
      authorize! current_user, to: :update?, with: UserPolicy

      user.update!(attributes)
    end
  end
end
