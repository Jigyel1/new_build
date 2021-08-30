module Enumable
  module Project
    extend ActiveSupport::Concern

    included do
      enum assignee_type: { kam: 'KAM Project', nbo: 'NBO Project' }
      enum entry_type: { manual: 'Manual', info_manager: 'Info Manager' }

      enum status: {
        technical_analysis: 'Technical Analysis',
        pct_calculation: 'PCT Calculation', # TODO - remove this status
        technical_analysis_completed: 'Technical Analysis Completed/On-Hold Meeting',
        ready_for_offer: 'Ready for Offer',
        contract: 'Contract',
        contract_accepted: 'Contract Accepted',
        under_construction: 'Under Construction'
      }

      # 'Marketing only' and 'Irrelevant' to be added later.
      enum category: {
        standard: 'Standard',
        complex: 'Complex'
      }

      enum type: {
        proactive: 'Proactive',
        reactive: 'Reactive',
        customer_request: 'Customer Request'
      }

      enum construction_type: {
        reconstruction: 'Reconstruction',
        new_construction: 'New Construction',
        b2b_new: 'B2B (New)',
        b2b_reconstruction: 'B2B (Reconstruction)',
        overbuild: 'Overbuild'
      }
    end
  end
end