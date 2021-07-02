# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdatePctValues < BaseMutation
      class UpdatePctValuesAttributes < Types::BaseInputObject
        argument :pct_values, [[String]], required: true
      end

      argument :attributes, UpdatePctValuesAttributes, required: true
      field :pct_values, [Types::AdminToolkit::PctValueType], null: true

      def resolve(attributes:)
        ::AdminToolkit::PctValuesUpdater.new(current_user: current_user, attributes: attributes.pct_values).call

        { pct_values: ::AdminToolkit::PctValue.all }
      end
    end
  end
end
