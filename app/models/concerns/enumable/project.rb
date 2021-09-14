module Enumable
  module Project
    extend ActiveSupport::Concern

    included do
      enum assignee_type: { kam: 'KAM Project', nbo: 'NBO Project' }
      enum entry_type: { manual: 'Manual', info_manager: 'Info Manager' }

      enum status: {
        open: 'Open',
        technical_analysis: 'Technical Analysis',
        pct_calculation: 'PCT Calculation', # TODO - remove this status
        technical_analysis_completed: 'Technical Analysis Completed/On-Hold Meeting',
        ready_for_offer: 'Ready for Offer',
        contract: 'Contract',
        contract_accepted: 'Contract Accepted',
        under_construction: 'Under Construction'
      }

      enum category: {
        standard: 'Standard',
        complex: 'Complex',
        marketing_only: 'Marketing Only',
        irrelevant: 'Irrelevant'
      }

      enum priority: {
        proactive: 'Proactive',
        reactive: 'Reactive'
      }

      enum construction_type: {
        reconstruction: 'Reconstruction',
        new_construction: 'New Construction',
        b2b_new: 'B2B (New)',
        b2b_reconstruction: 'B2B (Reconstruction)',
        overbuild: 'Overbuild'
      }

      enum access_technology: {
        ftth: 'FTTH',
        hfc: 'HFC',
        lease: 'Lease'
      }
    end
  end
end