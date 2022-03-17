# frozen_string_literal: true

module Projects
  class ExistingPctUpdater < BaseService
    attr_accessor :connection_cost_id

    def call
      assign_attributes(attributes)
      ::Projects::ConnectionCost.find_by(id: connection_cost_id).pct_cost.update!(attributes)
    end
  end
end
