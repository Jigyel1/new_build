# frozen_string_literal: true

module AdminToolkit
  class FootprintValue < ApplicationRecord
    belongs_to :footprint_building
    belongs_to :footprint_type

    enum project_type: {
      standard: 'Standard',
      complex: 'Complex',
      marketing_only: 'Marketing Only',
      irrelevant: 'Irrelevant'
    }

    validates(
      :project_type,
      presence: true,
      uniqueness: { scope: %i[footprint_building_id footprint_type_id], case_sensitive: false }
    )
  end
end
