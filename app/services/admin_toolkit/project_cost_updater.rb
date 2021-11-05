# frozen_string_literal: true

module AdminToolkit
  class ProjectCostUpdater < BaseService
    def project_cost
      @project_cost ||= AdminToolkit::ProjectCost.instance
    end

    def call
      authorize! project_cost, to: :update?, with: AdminToolkitPolicy

      with_tracking { project_cost.update!(attributes) }
    end

    private

    def activity_params
      {
        action: :project_cost_updated,
        owner: current_user,
        trackable: project_cost,
        parameters: attributes
      }
    end
  end
end
