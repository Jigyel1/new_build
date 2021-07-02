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
        resolver = ::AdminToolkit::PctMonthUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call

        { pct_month: resolver.pct_month }
      end
    end
  end
end
