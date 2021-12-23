# frozen_string_literal: true

module Projects
  module LeaseCosts
    module Ftth
      class SfnBig4Calculator < BaseService
        include PctCostHelper

        def call
          (ftth_payback_in_years * customers_count * mrc_sfn * MONTHS_IN_A_YEAR) +
            (customers_count * iru_sfn) + cpe_ftth + olt_cost_per_customer + patching_cost
        end
      end
    end
  end
end
