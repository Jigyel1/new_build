# frozen_string_literal: true

# “Admin toolkit HFC Payback” x “number of customers” #units x #penetration@zipcode x 20CHF (MRC standard) x 12 months
#
module Projects
  module LeaseCosts
    module Hfc
      class SfnBig4Calculator < BaseService
        include PctCostHelper

        def call
          hfc_payback_in_years * customers_count * mrc_standard * MONTHS_IN_A_YEAR
        end
      end
    end
  end
end
