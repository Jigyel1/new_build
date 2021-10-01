# frozen_string_literal: true

module Projects
  class PaybackPeriodUpdater < BaseService
    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        project_pct_cost.update!(
          payback_period: attributes[:months],
          system_generated_payback_period: false
        )
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def project
      @_project ||= Project.find(attributes[:project_id])
    end

    private

    def project_pct_cost
      @_project_pct_cost ||= project.pct_cost || project.build_pct_cost
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :payback_period_updated,
        owner: current_user,
        trackable: project_pct_cost,
        parameters: attributes
      }
    end
  end
end
