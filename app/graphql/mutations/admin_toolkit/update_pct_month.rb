# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdatePctMonth < BaseMutation
      class UpdatePctMonthAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :max, Int, required: true
      end

      argument :attributes, UpdatePctMonthAttributes, required: true
      field :pct_month, Types::AdminToolkit::PctMonthType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::PctMonthUpdater, :pct_month, attributes: attributes.to_h)
      end
    end
  end
end
