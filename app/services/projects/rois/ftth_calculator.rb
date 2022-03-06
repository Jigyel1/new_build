# frozen_string_literal: true

module Projects
  module Rois
    class FtthCalculator < BaseService
      include PctCostHelper
      attr_accessor :build_cost, :lease_cost

      def call
        super do
          ftth_payback * build_cost / lease_cost
        end
      end
    end
  end
end
