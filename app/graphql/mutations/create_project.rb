# frozen_string_literal: true

module Mutations
  class CreateProject < BaseMutation
    class AddressAttributes < Types::BaseInputObject
      graphql_name 'CreateProjectAddressAtttributes'

      argument :street, String, required: true
      argument :street_no, String, required: true
      argument :city, String, required: true
      argument :zip, String, required: true
    end

    class CreateProjectAttributes < Types::BaseInputObject
      argument :external_id, ID, required: false
      argument :name, String, required: true
      argument :status, String, required: false
      argument :description, String, required: false
      argument :additional_info, String, required: false
      argument :coordinate_east, Float, required: false
      argument :coordinate_north, Float, required: false

      argument :assignee_id, ID, required: false
      argument :lot_number, String, required: false
      argument :buildings, Int, required: false
      argument :apartments, Int, required: false

      argument :move_in_starts_on, GraphQL::Types::ISO8601DateTime, required: false
      argument :move_in_ends_on, GraphQL::Types::ISO8601DateTime, required: false
      argument :construction_starts_on, GraphQL::Types::ISO8601DateTime, required: false

      argument :address, AddressAttributes, required: false, as: :address_attributes
    end

    argument :attributes, CreateProjectAttributes, required: true
    field :project, Types::ProjectType, null: true

    def resolve(attributes:)
      resolver = ::Projects::Creator.new(current_user: current_user, attributes: attributes.to_h)
      resolver.call
      { project: resolver.project }
    end
  end
end
