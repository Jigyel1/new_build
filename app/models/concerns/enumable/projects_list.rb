# frozen_string_literal: true

module Enumable
  module ProjectsList
    extend ActiveSupport::Concern

    included do
      enum assignee_type: { kam: 'KAM Project', nbo: 'NBO Project' }
      enum priority: { proactive: 'Proactive', reactive: 'Reactive' }

      enum status: {
        open: 'Open',
        technical_analysis: 'Technical Analysis',
        technical_analysis_completed: 'Technical Analysis Completed',
        ready_for_offer: 'Ready for Offer',
        contract: 'Contract',
        contract_accepted: 'Contract Accepted',
        under_construction: 'Under Construction',
        commercialization: 'Commercialization',
        archived: 'Archived',
        offer_confirmation: 'Offer Confirmation'
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
        transformation: 'Transformation',
        pre_invest: 'Pre Invest',
        overbuild: 'Overbuild'
      }

      enum confirmation_status: {
        new_offer: 'New',
        negotiation: 'Negotiation',
        offered: 'Offered',
        signed: 'Signed',
        internal_clarification: 'Internal Clarification',
        customer_not_interested: 'Customer Not Interested'
      }
    end
  end
end
