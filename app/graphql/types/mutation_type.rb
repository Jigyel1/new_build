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

    field :update_footprint_building, mutation: Mutations::AdminToolkit::UpdateFootprintBuilding
    field :update_footprint_values, mutation: Mutations::AdminToolkit::UpdateFootprintValues

    field :update_label, mutation: Mutations::AdminToolkit::UpdateLabels
    field :update_project_cost, mutation: Mutations::AdminToolkit::UpdateProjectCost

    field :create_penetration, mutation: Mutations::AdminToolkit::CreatePenetration
    field :update_penetration, mutation: Mutations::AdminToolkit::UpdatePenetration
    field :delete_penetration, mutation: Mutations::AdminToolkit::DeletePenetration
    field :update_kam_regions, mutation: Mutations::AdminToolkit::UpdateKamRegions

    field :create_competition, mutation: Mutations::AdminToolkit::CreateCompetition
    field :update_competition, mutation: Mutations::AdminToolkit::UpdateCompetition
    field :delete_competition, mutation: Mutations::AdminToolkit::DeleteCompetition

    field :create_kam_investor, mutation: Mutations::AdminToolkit::CreateKamInvestor
    field :update_kam_investor, mutation: Mutations::AdminToolkit::UpdateKamInvestor
    field :delete_kam_investor, mutation: Mutations::AdminToolkit::DeleteKamInvestor
  end
end
