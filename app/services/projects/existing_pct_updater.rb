# frozen_string_literal: true

module Projects
  class ExistingPctUpdater < BaseService
    attr_accessor(
      :project_cost,
      :socket_installation_cost,
      :project_connection_cost,
      :lease_cost,
      :penetration_rate,
      :payback_period,
      :roi,
      :build_cost,
      :system_generated_payback_period,
      :connection_cost_id
    )

    def call
      assign_attributes(attributes)
      ::Projects::ConnectionCost.find_by(id: connection_cost_id).pct_cost.update!(attributes)
    end
  end
end
