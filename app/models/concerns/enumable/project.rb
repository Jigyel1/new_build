# frozen_string_literal: true

module Enumable
  module Project
    extend ActiveSupport::Concern

    included do
      enum entry_type: { manual: 'Manual', info_manager: 'Info Manager' }
      enum priority: { proactive: 'Proactive', reactive: 'Reactive' }
      enum priority_tac: { proactive: 'Proactive', reactive: 'Reactive' }, _suffix: :tac
      enum access_technology: { ftth: 'FTTH', hfc: 'HFC', third_party: 'Third Party' }
      enum access_technology_tac: { ftth: 'FTTH', hfc: 'HFC', third_party: 'Third Party' }, _suffix: :tac
      enum confirmation_status: { new: 'New', negotiation: 'Negotiation', offered: 'Offered', signed: 'Signed' }

      enum building_type: {
        efh: 'EFH',
        defh: 'DEFH',
        mfh: 'MFH',
        refh: 'Non-Residential REFH',
        stepped_building: 'Stepped Building',
        restaurant: 'Restaurant',
        school: 'School',
        hospital: 'Hospital',
        nursing: 'Nursing',
        retirement_homes: 'Retirement Homes',
        others: 'Others'
      }
    end
  end
end
