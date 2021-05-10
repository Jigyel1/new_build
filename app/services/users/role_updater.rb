# frozen_string_literal: true

module Users
  class RoleUpdater < BaseService
    include UserFinder

    # TODO: Once the projects module is ready, need to reassign projects as per
    # `https://app.clickup.com/t/7nu94j`
    def call
      authorize! current_user, to: :update_role?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        previous_role = user.role_name
        user.update!(role_id: attributes[:roleId])

        Activities::ActivityCreator.new(
          activity_params(activity_id, :role_updated, { role: user.role_name, previous_role: previous_role })
        ).call
      end
    end
  end
end
