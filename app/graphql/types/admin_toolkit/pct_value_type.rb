# frozen_string_literal: true

module Types
  module AdminToolkit
    class PctValueType < BaseObject
      field :id, ID, null: true
      field :status, String, null: true
      field :pct_cost, PctCostType, null: true
      field :pct_month, PctMonthType, null: true

      def status
        ::AdminToolkit::PctValue.statuses[object.status]
      end
    end
  end
end
