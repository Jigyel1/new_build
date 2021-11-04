# frozen_string_literal: true

module Users
  class RoleUpdater < BaseService
    include ActivityHelper
    include UserFinder

    set_callback :call, :before, :role_changed?

    # TODO: Once the projects module is ready, need to reassign projects as per user
    def call
      authorize! user, to: :update_role?, with: UserPolicy

      user.assign_attributes(role_id: attributes[:role_id])
      @previous_role = role_name(Role.find(user.role_id_was).name)

      with_tracking(create_activity: role_changed?) do
        super { user.save! }
      end
    end

    private

    def activity_params
      super(:role_updated, { role: role_name(user.role_name), previous_role: @previous_role })
    end

    def role_name(key)
      Role.names[key]
    end

    def role_changed?
      @role_changed ||= user.role_id_changed?
    end
  end
end
