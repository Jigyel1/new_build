# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    # field :update_profile, mutation: Mutations::Users::UpdateProfile, description: <<~DESC
    #   Use this endpoint to update user's own profile
    # DESC

    field :update_user, mutation: Mutations::UpdateUser, description: <<~DESC
      Use this endpoint to update someone else's profile
    DESC

    field :delete_user, mutation: Mutations::DeleteUser
  end
end
