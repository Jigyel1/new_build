# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field(
      :update_user,
      mutation: Mutations::UpdateUser,
      description: 'Update basic user attributes like firstname, lastname etc.'
    )

    field(
      :update_user_status,
      mutation: Mutations::UpdateUserStatus,
      description: 'Activate or deactivate user'
    )

    field :update_user_role, mutation: Mutations::UpdateUserRole
    field :delete_user, mutation: Mutations::DeleteUser
    field :upload_avatar, mutation: Mutations::UploadAvatar

    field :export_activities, mutation: Mutations::ExportActivities

    field :update_pct_cost, mutation: Mutations::AdminToolkit::UpdatePctCost
    field :update_pct_month, mutation: Mutations::AdminToolkit::UpdatePctMonth
    field :update_pct_values, mutation: Mutations::AdminToolkit::UpdatePctValues
  end
end
