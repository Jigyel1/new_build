# frozen_string_literal: true

module AdminToolkit
  class PctMonth < ApplicationRecord
    has_many :admin_toolkit_pct_values, class_name: 'AdminToolkit::PctValue'

    validates :min, :max, numericality: { greater_than_or_equal_to: 1 }
    validates :max, numericality: { greater_than_or_equal_to: :min }
    validates :index, uniqueness: true
  end
end
