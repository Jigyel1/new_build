# frozen_string_literal: true

module AdminToolkit
  class FootprintValue < ApplicationRecord
    belongs_to :footprint_building
    belongs_to :footprint_type

    enum category: {
      standard: 'Standard',
      complex: 'Complex',
      marketing_only: 'Marketing Only',
      irrelevant: 'Irrelevant'
    }

    validates(
      :category,
      presence: true,
      uniqueness: { scope: %i[footprint_building_id footprint_type_id], case_sensitive: false }
    )

    default_scope do
      joins(:footprint_building, :footprint_type).order(
        'admin_toolkit_footprint_buildings.index, admin_toolkit_footprint_types.index'
      )
    end
  end
end
