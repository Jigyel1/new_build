# frozen_string_literal: true

module Projects
  module BuildCosts
    class FtthCalculator < BaseService
      include PctCostHelper
      attr_accessor :project_cost

      def call
        super { (project_cost + (customers_count * cpe_ftth) + (apartments_count * olt_cost_per_unit)) }
      end
    end
  end
end
