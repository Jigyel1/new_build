# frozen_string_literal: true

module Users
  class UserDeleter < BaseService
    TIME_FORMAT = '%Y_%m_%d_%H_%M'
    include UserFinder

    # after soft delete reset email so that next time the same user is added
    # you don't get email uniqueness error.
    # also prepending current time to maintain uniqueness of deleted records with same email.
    def call
      authorize! current_user, to: :delete?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        user.discard!

        Activities::ActivityCreator.new(
          activity_params(activity_id, :profile_deleted)
        ).call
      end

      user.update_column(
        :email, user.email.prepend(Time.current.strftime("#{TIME_FORMAT}_"))
      )
    end
  end
end
