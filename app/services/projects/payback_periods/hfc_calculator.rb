# frozen_string_literal: true

module Projects
  module PaybackPeriods
    class HfcCalculator < BaseService
      include PctCostHelper
      attr_accessor :build_cost, :lease_cost

      def call
        super { hfc_payback * (build_cost / lease_cost) }
      end
    end
  end
end
