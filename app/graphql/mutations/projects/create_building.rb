# frozen_string_literal: true

module Mutations
  module Projects
    class CreateBuilding < BaseMutation
      class CreateBuildingAddressAttributes < Types::BaseInputObject
        argument :street, String, required: false
        argument :street_no, String, required: false
        argument :city, String, required: false
        argument :zip, String, required: false
      end

      class CreateBuildingAttributes < Types::BaseInputObject
        argument :name, String, required: false
        argument :project_id, String, required: true
        argument :apartments_count, Int, required: true

        argument :external_id, String, required: false
        argument :move_in_starts_on, GraphQL::Types::ISO8601DateTime, required: true

        argument :address, CreateBuildingAddressAttributes, as: :address_attributes, required: false
      end

      argument :attributes, CreateBuildingAttributes, required: true
      field :building, Types::Projects::BuildingType, null: true

      def resolve(attributes:)
        super(::Projects::BuildingCreator, :building, attributes: attributes.to_h)
      end
    end
  end
end
