# frozen_string_literal: true

module Users
  class StatusUpdater < BaseService
    include UserFinder

    def call
      authorize! current_user, to: :update_status?, with: UserPolicy

      user.update!(active: attributes[:active])

      ActivityPopulator.new(
        owner: current_user,
        recipient: user,
        verb: :status_updated,
        trackable_type: 'User',
        parameters: attributes
      ).log_activity
    end
  end
end
