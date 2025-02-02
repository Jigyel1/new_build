# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateFootprintValues < BaseMutation
      class UpdateFootprintValuesAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :category, String, required: true
      end

      argument :attributes, [UpdateFootprintValuesAttributes], required: true
      field :footprint_values, [Types::AdminToolkit::FootprintValueType], null: true

      def resolve(attributes:)
        ::AdminToolkit::FootprintValuesUpdater.new(
          current_user: current_user,
          attributes: attributes.map(&:to_h)
        ).call

        { footprint_values: ::AdminToolkit::FootprintValue.all }
      end
    end
  end
end
