# frozen_string_literal: true

module Mutations
  class CreateProject < BaseMutation
    class AddressAttributes < Types::BaseInputObject
      graphql_name 'CreateProjectAddressAtttributes'
      include Concerns::Address
    end

    class AddressBooksAttributes < Types::BaseInputObject
      argument :type, String, required: true
      argument :name, String, required: true
      argument :display_name, String, required: false, description: <<~DESC
        For architect & investor, display name will be set the same as the type. If the type is
        others, display name will have a custom name and is REQUIRED!.
      DESC

      argument :additional_name, String, required: false
      argument :company, String, required: true
      argument :po_box, String, required: false
      argument :language, String, required: false
      argument :phone, String, required: true
      argument :mobile, String, required: true
      argument :email, String, required: true
      argument :website, String, required: true

      argument :address, AddressAttributes, as: :address_attributes, required: false
    end

    class CreateProjectAttributes < Types::BaseInputObject
      argument :external_id, ID, required: true
      argument :name, String, required: true
      argument :status, String, required: true

      # Commenting out assignee id for now. System is suppose to pick on that from the AdminToolkit::KamRegion
      # or AdminToolkit::KamMapping
      # argument :assignee_id, ID, required: false
      argument :lot_number, String, required: true
      argument :buildings, Int, required: true
      argument :apartments, Int, required: true

      argument :move_in_starts_on, String, required: true
      argument :move_in_ends_on, String, required: true
      argument :construction_starts_on, String, required: true

      argument :address, AddressAttributes, as: :address_attributes, required: true

      # Beyond this, project can be saved as draft. So address books are optional.
      argument :address_books, [AddressBooksAttributes], as: :address_books_attributes, required: false
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
