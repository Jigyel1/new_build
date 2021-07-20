# frozen_string_literal: true

module AdminToolkit
  class PctCost < ApplicationRecord
    has_many :admin_toolkit_pct_values, class_name: 'AdminToolkit::PctValue', dependent: :restrict_with_error

    validates :min, :max, numericality: { greater_than_or_equal_to: 0 }
    validates :max, numericality: { greater_than_or_equal_to: :min }
    validates :index, uniqueness: true
  end
end
