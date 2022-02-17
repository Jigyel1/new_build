# frozen_string_literal: true

module Projects
  module LeaseCosts
    module Ftth
      class SwisscomFtthCalculator < BaseService
        include PctCostHelper

        def call
          multiplier = ftth_payback * customers_count * MONTHS_IN_A_YEAR * high_tiers_product_share_percentage
          (multiplier * mrc_standard) + (multiplier * mrc_high_tiers)
        end
      end
    end
  end
end
