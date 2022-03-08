# frozen_string_literal: true

module Projects
  module LeaseCosts
    module Hfc
      class SwisscomDslCalculator < BaseService
        include PctCostHelper

        def call
          hfc_payback * customers_count * mrc_standard * MONTHS_IN_A_YEAR
        end
      end
    end
  end
end
