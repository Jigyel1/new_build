# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateFootprintApartment < BaseMutation
      class UpdateFootprintApartmentAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :max, Int, required: true
      end

      argument :attributes, UpdateFootprintApartmentAttributes, required: true
      field :footprint_apartment, Types::AdminToolkit::FootprintApartmentType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::FootprintApartmentUpdater, :footprint_apartment, attributes: attributes.to_h)
      end
    end
  end
end
