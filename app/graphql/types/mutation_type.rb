# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # field :update_profile, mutation: Mutations::Users::UpdateProfile, description: <<~DESC
    #   Use this endpoint to update user's own profile
    # DESC

    field(
      :update_user,
      mutation: Mutations::UpdateUser,
      description: "Use this endpoint to update someone else's profile"
    )

    field(
      :update_user_status,
      mutation: Mutations::UpdateUserStatus,
      description: 'Activate or deactivate user'
    )

    field :update_user_role, mutation: Mutations::UpdateUserRole
    field :delete_user, mutation: Mutations::DeleteUser
  end
end
