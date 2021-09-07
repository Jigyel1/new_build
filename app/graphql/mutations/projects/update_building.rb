# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateBuilding < BaseMutation
      class UpdateBuildingAddressAttributes < Types::BaseInputObject
        include Concerns::Address
      end

      class UpdateBuildingAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :name, String, required: false
        argument :assignee_id, ID, required: false
        argument :apartments_count, Int, required: false
        argument :move_in_starts_on, GraphQL::Types::ISO8601DateTime, required: false
        argument :move_in_ends_on, GraphQL::Types::ISO8601DateTime, required: false
        argument :address, UpdateBuildingAddressAttributes, as: :address_attributes, required: false
      end

      argument :attributes, UpdateBuildingAttributes, required: true
      field :building, Types::Projects::BuildingType, null: true

      def resolve(attributes:)
        super(::Projects::BuildingUpdater, :building, attributes: attributes)
      end
    end
  end
end
