# frozen_string_literal: true

module Users
  class RoleUpdater < BaseService
    include UserFinder

    # TODO: Once the projects module is ready, need to reassign projects as per
    # https://app.clickup.com/t/7nu94j
    #
    def call
      authorize! current_user, to: :update_role?, with: UserPolicy

      user.update!(role_id: attributes[:roleId])
    end
  end
end
