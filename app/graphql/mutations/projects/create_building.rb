# frozen_string_literal: true

module Mutations
  module Projects
    class CreateBuilding < BaseMutation
      class CreateBuildingAddressAttributes < Types::BaseInputObject
        argument :street, String, required: true
        argument :street_no, String, required: true
        argument :city, String, required: true
        argument :zip, String, required: true
      end

      # TODO: Sort out required true followed by required false.
      class CreateBuildingAttributes < Types::BaseInputObject
        argument :project_id, String, required: true
        argument :external_id, String, required: false
        argument :name, String, required: true
        argument :assignee_id, String, required: true

        argument :apartments_count, Int, required: true
        argument :move_in_starts_on, GraphQL::Types::ISO8601DateTime, required: false
        argument :move_in_ends_on, GraphQL::Types::ISO8601DateTime, required: false

        argument :address, CreateBuildingAddressAttributes, as: :address_attributes, required: false
      end

      argument :attributes, CreateBuildingAttributes, required: true
      field :building, Types::Projects::BuildingType, null: true

      def resolve(attributes:)
        resolver = ::Projects::BuildingCreator.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { building: resolver.building }
      end
    end
  end
end
