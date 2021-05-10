# frozen_string_literal: true

module Users
  class UserUpdater < BaseService
    include UserFinder

    def call
      authorize! current_user, to: :update?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        user.update!(attributes)

        Activities::ActivityCreator.new(
          activity_params(activity_id, :profile_updated, attributes)
        ).call
      end
    end
  end
end
