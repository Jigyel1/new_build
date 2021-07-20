# frozen_string_literal: true

module AdminToolkit
  class FootprintBuilding < ApplicationRecord
    has_many(
      :admin_toolkit_footprint_values,
      class_name: 'AdminToolkit::FootprintValue',
      dependent: :restrict_with_error
    )

    validates :min, :max, numericality: { greater_than: 0 }
    validates :max, numericality: { greater_than_or_equal_to: :min }
    validates :index, uniqueness: true
  end
end
