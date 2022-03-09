# frozen_string_literal: true

module Types
  module AdminToolkit
    class CostThresholdType < BaseObject
      field :id, ID, null: true
      field :exceeding, Float, null: true
    end
  end
end
