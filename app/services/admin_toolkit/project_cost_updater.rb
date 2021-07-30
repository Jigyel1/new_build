# frozen_string_literal: true

module AdminToolkit
  class ProjectCostUpdater < BaseService
    def project_cost
      @project_cost ||= AdminToolkit::ProjectCost.instance
    end

    def call
      authorize! project_cost, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        project_cost.update!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_cost_updated,
        owner: current_user,
        trackable: project_cost,
        parameters: attributes
      }
    end
  end
end
