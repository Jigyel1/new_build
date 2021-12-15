# frozen_string_literal: true

module Projects
  class ConnectionCost < ApplicationRecord
    belongs_to :project

    enum connection_type: { hfc: 'HFC', ftth: 'FTTH' }

    validates :connection_type, :cost, presence: true
    validates :standard_cost, :too_expensive, inclusion: { in: [true, false] }
    validates :connection_type, uniqueness: { scope: :project_id }

    before_validation :set_cost

    private

    def set_cost
      return unless standard_cost?

      # TODO: Add conditional logic based on project category
      #   For complex projects, the value will be different. To be added once we get the details from BA.
      self.cost ||= AdminToolkit::ProjectCost.instance.standard
    end
  end
end
