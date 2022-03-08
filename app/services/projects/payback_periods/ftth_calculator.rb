# frozen_string_literal: true

module Projects
  module PaybackPeriods
    class FtthCalculator < BaseService
      include PctCostHelper
      attr_accessor :build_cost, :lease_cost

      def call
        super { ftth_payback * (build_cost / lease_cost) }
      end
    end
  end
end
