# frozen_string_literal: true

module Users
  class UserUpdater < BaseService
    include UserFinder

    def call
      authorize! current_user, to: :update?, with: UserPolicy

      user.update!(attributes)

      ActivityPopulator.new(
        owner: current_user,
        recipient: user,
        verb: :profile_updated,
        trackable_type: 'User',
        parameters: attributes
      ).log_activity
    end
  end
end
