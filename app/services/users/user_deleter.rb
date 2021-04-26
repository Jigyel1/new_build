# frozen_string_literal: true

module Users
  class UserDeleter < BaseService
    include UserFinder

    TIME_FORMAT = '%Y_%m_%d_%H_%M'

    # after soft delete reset email so that next time the same user is added
    # you don't get email uniqueness error.
    # also prepending current time to maintain uniqueness of deleted records with same email.
    #
    def call
      authorize! current_user, to: :delete?, with: UserPolicy

      user.discard!.tap do
        user.update_column(
          :email, user.email.prepend(Time.current.strftime("#{TIME_FORMAT}_"))
        )
      end
    end
  end
end
