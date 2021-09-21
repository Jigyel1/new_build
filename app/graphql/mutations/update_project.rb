# frozen_string_literal: true

module Mutations
  class UpdateProject < BaseMutation
    # id is still optional. you can still add an address to an already created project.
    class AddressAttributes < Types::BaseInputObject
      graphql_name 'UpdateProjectAddressAtttributes'
      include Concerns::Address
    end

    class UpdateProjectAttributes < Types::BaseInputObject
      argument :id, ID, required: true
      argument :internal_id, ID, required: false
      argument :name, String, required: false
      argument :status, String, required: false
      argument :description, String, required: false
      argument :additional_info, String, required: false
      argument :assignee_id, ID, required: false

      argument :coordinate_east, Float, required: false
      argument :coordinate_north, Float, required: false

      argument :lot_number, String, required: false
      argument :move_in_starts_on, String, required: false
      argument :move_in_ends_on, String, required: false
      argument :construction_starts_on, String, required: false

      argument :address, AddressAttributes, required: false, as: :address_attributes
    end

    argument :attributes, UpdateProjectAttributes, required: true
    field :project, Types::ProjectType, null: true

    def resolve(attributes:)
      resolver = ::Projects::Updater.new(current_user: current_user, attributes: attributes.to_h)
      resolver.call
      { project: resolver.project }
    end
  end
end
