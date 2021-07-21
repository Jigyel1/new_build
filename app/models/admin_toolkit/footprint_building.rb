# frozen_string_literal: true

module AdminToolkit
  class FootprintBuilding < ApplicationRecord
    has_many(
      :footprint_values,
      class_name: 'AdminToolkit::FootprintValue',
      dependent: :restrict_with_error
    )

    validates :min, :max, :index, presence: true
    validates :min, :max, numericality: { only_integer: true, greater_than: 0 }
    validates :max, numericality: { greater_than_or_equal_to: :min }
    validates :index, uniqueness: true

    default_scope { order(:index) }
  end
end
