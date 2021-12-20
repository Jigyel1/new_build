# frozen_string_literal: true

module Projects
  class ConnectionCost < ApplicationRecord
    belongs_to :project

    enum connection_type: { hfc: 'HFC', ftth: 'FTTH' }
    enum cost_type: { standard: 'Standard Cost', non_standard: 'Non Standard Cost', too_expensive: 'Too Expensive' }

    validates :connection_type, :cost_type, presence: true
    validates :connection_type, uniqueness: { scope: :project_id }
  end
end
