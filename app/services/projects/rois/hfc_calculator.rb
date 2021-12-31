# frozen_string_literal: true

module Projects
  module Rois
    class HfcCalculator < BaseService
      include PctCostHelper
      attr_accessor :build_cost, :lease_cost

      def call
        super do
          hfc_payback_in_years * build_cost / lease_cost
        end
      end
    end
  end
end
