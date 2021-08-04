# frozen_string_literal: true

module Mutations
  class CreateProject < BaseMutation
    class AddressAttributes < Types::BaseInputObject
      graphql_name 'CreateProjectAddressAtttributes'
      include Concerns::Address
    end

    class CreateProjectAttributes < Types::BaseInputObject
      argument :external_id, ID, required: true
      argument :name, String, required: false
      argument :status, String, required: false
      argument :assignee_id, ID, required: false
      argument :lot_number, String, required: false
      argument :buildings, Int, required: false
      argument :apartments, Int, required: false

      argument :move_in_starts_on, String, required: false
      argument :move_in_ends_on, String, required: false
      argument :construction_starts_on, String, required: false

      argument :address, AddressAttributes, as: :address_attributes, required: false
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
