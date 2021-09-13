# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdatePctValues < BaseMutation
      class UpdatePctValuesAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :status, String, required: true
      end

      argument :attributes, [UpdatePctValuesAttributes], required: true
      field :pct_values, [Types::AdminToolkit::PctValueType], null: true

      def resolve(attributes:)
        ::AdminToolkit::PctValuesUpdater.new(current_user: current_user, attributes: attributes.map(&:to_h)).call

        { pct_values: ::AdminToolkit::PctValue.includes(:pct_cost, :pct_month) }
      end
    end
  end
end
