# frozen_string_literal: true

module Users
  class RoleUpdater < BaseService
    include UserFinder

    # TODO: Once the projects module is ready, need to reassign projects as per
    # `https://app.clickup.com/t/7nu94j`
    def call
      authorize! current_user, to: :update_role?, with: UserPolicy

      user.update!(role_id: attributes[:roleId])

      ActivityPopulator.new(
        owner: current_user,
        recipient: user,
        verb: :role_updated,
        trackable_type: 'User',
        parameters: { role: user.role_name }
      ).log_activity
    end
  end
end
