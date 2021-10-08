# frozen_string_literal: true

module Activities
  module CallbackActivityParams
    def analysis_params(activity_id)
      {
        activity_id: activity_id,
        action: :technical_analysis,
        owner: current_user,
        trackable: project,
        parameters: {
          status: project.status,
          project_name: project.name
        }
      }
    end

    def analysis_completed_params(activity_id)
      {
        activity_id: activity_id,
        action: :technical_analysis_completed,
        owner: current_user,
        trackable: project,
        parameters: {
          status: project.status,
          project_name: project.name
        }
      }
    end

    def offer_ready_params(activity_id)
      {
        activity_id: activity_id,
        action: :ready_for_offer,
        owner: current_user,
        trackable: project,
        parameters: {
          previous_status: project.previous_changes.dig('status', 0),
          status: project.status,
          project_name: project.name
        }
      }
    end

    def archive_params(activity_id)
      {
        activity_id: activity_id,
        action: :archived,
        owner: current_user,
        trackable: project,
        parameters: {
          previous_status: project.previous_changes.dig('status', 0),
          project_name: project.name
        }
      }
    end

    def revert_params(activity_id)
      {
        activity_id: activity_id,
        action: :reverted,
        owner: current_user,
        trackable: project,
        parameters: {
          previous_status: project.previous_changes.dig('status', 0),
          status: project.status,
          project_name: project.name
        }
      }
    end
  end
end
