# frozen_string_literal: true

module AdminToolkit
  class CostThreshold < ApplicationRecord
    validates :not_exceeding, :exceeding, presence: true
    validates :not_exceeding, :exceeding, numericality: { only_float: true, greater_than_or_equal_to: 0 }
    validates :exceeding, numericality: { greater_than_or_equal_to: :not_exceeding }
  end
end
