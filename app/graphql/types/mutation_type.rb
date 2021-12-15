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

    field :update_footprint_apartment, mutation: Mutations::AdminToolkit::UpdateFootprintApartment
    field :update_footprint_values, mutation: Mutations::AdminToolkit::UpdateFootprintValues

    field :update_labels, mutation: Mutations::AdminToolkit::UpdateLabels
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

    field :create_offer_content, mutation: Mutations::AdminToolkit::CreateOfferContent
    field :update_offer_content, mutation: Mutations::AdminToolkit::UpdateOfferContent
    field :delete_offer_content, mutation: Mutations::AdminToolkit::DeleteOfferContent

    field :create_project, mutation: Mutations::CreateProject
    field :update_project, mutation: Mutations::UpdateProject
    field :import_projects, mutation: Mutations::ImportProjects
    field :export_projects, mutation: Mutations::ExportProjects
    field :update_project_category, mutation: Mutations::Projects::UpdateCategory

    field :revert_project_transition, mutation: Mutations::Projects::RevertTransition

    field :transition_to_technical_analysis, mutation: Mutations::Projects::TransitionToTechnicalAnalysis
    field(
      :transition_to_technical_analysis_completed,
      mutation: Mutations::Projects::TransitionToTechnicalAnalysisCompleted
    )
    field :transition_to_ready_for_offer, mutation: Mutations::Projects::TransitionToReadyForOffer
    field :archive_project, mutation: Mutations::Projects::ArchiveProject
    field :unarchive_project, mutation: Mutations::Projects::UnarchiveProject

    field :assign_project_incharge, mutation: Mutations::Projects::AssignIncharge
    field :unassign_project_incharge, mutation: Mutations::Projects::UnassignIncharge
    field :update_payback_period, mutation: Mutations::Projects::UpdatePaybackPeriod

    field :save_draft, mutation: Mutations::Projects::SaveDraft

    field :create_address_book, mutation: Mutations::Projects::CreateAddressBook
    field :update_address_book, mutation: Mutations::Projects::UpdateAddressBook
    field :delete_address_book, mutation: Mutations::Projects::DeleteAddressBook

    field :create_building, mutation: Mutations::Projects::CreateBuilding
    field :update_building, mutation: Mutations::Projects::UpdateBuilding
    field :import_buildings, mutation: Mutations::Projects::ImportBuildings
    field :delete_building, mutation: Mutations::Projects::DeleteBuilding
    field :export_building, mutation: Mutations::Projects::ExportBuilding

    field :create_task, mutation: Mutations::Projects::CreateTask
    field :delete_task, mutation: Mutations::Projects::DeleteTask
    field :update_task, mutation: Mutations::Projects::UpdateTask
    field :unarchive_task, mutation: Mutations::Projects::UnarchiveTask

    field :create_project_labels, mutation: Mutations::Projects::CreateLabels
    field :update_project_labels, mutation: Mutations::Projects::UpdateLabels

    field :upload_files, mutation: Mutations::Projects::UploadFiles
    field :update_file, mutation: Mutations::Projects::UpdateFile
    field :delete_file, mutation: Mutations::Projects::DeleteFile
  end
end
