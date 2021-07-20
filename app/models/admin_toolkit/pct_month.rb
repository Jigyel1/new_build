# frozen_string_literal: true

module AdminToolkit
  class PctMonth < ApplicationRecord
    has_many :admin_toolkit_pct_values, class_name: 'AdminToolkit::PctValue', dependent: :restrict_with_error

    validates :min, :max, :index, presence: true
    validates :min, :max, numericality: { greater_than_or_equal_to: 1, only_integer: true }
    validates :max, numericality: { greater_than_or_equal_to: :min }
    validates :index, uniqueness: true
  end
end
