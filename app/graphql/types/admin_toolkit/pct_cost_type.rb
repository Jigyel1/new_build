# frozen_string_literal: true

module Types
  module AdminToolkit
    class PctCostType < BaseObject
      field :id, ID, null: true
      field :index, Int, null: true
      field :min, Int, null: true
      field :max, Int, null: true
      field :header, String, null: true
    end
  end
end
