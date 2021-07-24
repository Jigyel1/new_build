# frozen_string_literal: true

module Users
  class RoleUpdater < BaseService
    include UserFinder

    set_callback :call, :before, :role_changed?

    # TODO: Once the projects module is ready, need to reassign projects as per user
    def call # rubocop:disable Metrics/AbcSize
      authorize! user, to: :update_role?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        user.assign_attributes(role_id: attributes[:roleId])
        previous_role = role_name(Role.find(user.role_id_was).name)
        super { user.save! }

        create_activity(activity_id, previous_role) if role_changed?
      end
    end

    private

    def create_activity(activity_id, previous_role)
      Activities::ActivityCreator.new(
        activity_params(
          activity_id, :role_updated,
          { role: role_name(user.role_name), previous_role: previous_role }
        )
      ).call
    end

    def role_name(key)
      Role.names[key]
    end

    def role_changed?
      @role_changed ||= user.role_id_changed?
    end
  end
end
