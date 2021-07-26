# frozen_string_literal: true

module Users
  class UserDeleter < BaseService
    TIME_FORMAT = '%Y_%m_%d_%H_%M'
    include ActivityHelper
    include UserFinder

    set_callback :call, :after, :update_email

    # after soft delete reset email so that next time the same user is added
    # you don't get email uniqueness error.
    # also prepending current time to maintain uniqueness of deleted records with same email.
    def call
      authorize! user, to: :delete?, with: UserPolicy

      super do
        with_tracking(activity_id = SecureRandom.uuid) do
          user.discard!

          # Can there be a possibility of a duplicate activity log if the user is already discarded?
          # Short answer - No. By virtue of the default scope where we don't show discarded users,
          # `UserFinder` will throw NotFound error at the very beginning.
          Activities::ActivityCreator.new(activity_params(activity_id, :profile_deleted)).call
        end
      end
    end

    private

    def update_email
      user.update_column(:email, user.email.prepend(Time.current.strftime("#{TIME_FORMAT}_")))
    end
  end
end
