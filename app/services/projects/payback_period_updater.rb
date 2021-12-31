# frozen_string_literal: true

module Projects
  class PaybackPeriodUpdater < BaseService
    delegate :project, to: :connection_cost

    def call
      authorize! project, to: :configure_technical_analysis?

      with_tracking do
        pct_cost.update!(
          payback_period: attributes[:months],
          system_generated_payback_period: false
        )
      end
    end

    private

    def connection_cost
      @_connection_cost ||= Projects::ConnectionCost.find(attributes[:connection_cost_id])
    end

    def pct_cost
      @_pct_cost ||= connection_cost.pct_cost || connection_cost.build_pct_cost
    end

    def activity_params
      {
        action: :payback_period_updated,
        owner: current_user,
        trackable: pct_cost,
        parameters: { project_name: project.name }
      }
    end
  end
end
