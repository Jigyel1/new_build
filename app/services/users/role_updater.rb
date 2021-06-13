# frozen_string_literal: true

module Users
  class RoleUpdater < BaseService
    include UserFinder

    # TODO: Once the projects module is ready, need to reassign projects as per

    private

    def process
      authorize! user, to: :update_role?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        previous_role = Role.names[user.role_name]
        user.update!(role_id: attributes[:roleId])
        create_activity(activity_id, previous_role)
      end
    end

    def execute?
      user.role_id != attributes.roleId
    end

    def create_activity(activity_id, previous_role)
      Activities::ActivityCreator.new(
        activity_params(
          activity_id,
          :role_updated,
          { role: Role.names[user.role_name], previous_role: previous_role }
        )
      ).call
    end
  end
end
