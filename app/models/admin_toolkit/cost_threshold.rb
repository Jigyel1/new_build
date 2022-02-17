# frozen_string_literal: true

module AdminToolkit
  class CostThreshold < ApplicationRecord
    validates(
      :exceeding,
      presence: true,
      numericality: { only_float: true, greater_than_or_equal_to: 0 }
    )
  end
end
