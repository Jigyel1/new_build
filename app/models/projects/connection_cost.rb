# frozen_string_literal: true

module Projects
  class ConnectionCost < ApplicationRecord
    belongs_to :project
    has_one :pct_cost, dependent: :destroy, class_name: 'Projects::PctCost'

    enum connection_type: { hfc: 'HFC', ftth: 'FTTH' }
    enum cost_type: { standard: 'Standard Cost', non_standard: 'Non Standard Cost', too_expensive: 'Too Expensive' }

    validates :connection_type, :cost_type, presence: true
  end
end
