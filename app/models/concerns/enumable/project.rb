# frozen_string_literal: true

module Enumable
  module Project
    extend ActiveSupport::Concern

    included do
      enum assignee_type: { kam: 'KAM Project', nbo: 'NBO Project' }
      enum entry_type: { manual: 'Manual', info_manager: 'Info Manager' }
      enum priority: { proactive: 'Proactive', reactive: 'Reactive' }
      enum access_technology: { ftth: 'FTTH', hfc: 'HFC', lease: 'Lease' }

      enum status: {
        open: 'Open',
        technical_analysis: 'Technical Analysis',
        technical_analysis_completed: 'Technical Analysis Completed',
        ready_for_offer: 'Ready for Offer',
        contract: 'Contract',
        contract_accepted: 'Contract Accepted',
        under_construction: 'Under Construction',
        archived: 'Archived'
      }

      enum category: {
        standard: 'Standard',
        complex: 'Complex',
        marketing_only: 'Marketing Only',
        irrelevant: 'Irrelevant'
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
