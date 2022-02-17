# frozen_string_literal: true

module Projects
  module BuildCosts
    class HfcCalculator < BaseService
      include PctCostHelper
      attr_accessor :project_cost

      def call
        super { project_cost + (customers_count * cpe_hfc) }
      end
    end
  end
end
