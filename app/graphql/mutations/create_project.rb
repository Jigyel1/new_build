# frozen_string_literal: true

module Mutations
  class CreateProject < BaseMutation
    class CreateProjectAddressAttributes < Types::BaseInputObject
      argument :street, String, required: false
      argument :street_no, String, required: false
      argument :city, String, required: false
      argument :zip, String, required: false
    end

    class CreateProjectAddressBookAttributes < Types::BaseInputObject
      include Concerns::AddressBook

      argument :type, String, required: true
      argument :name, String, required: false
      argument :address, CreateProjectAddressAttributes, as: :address_attributes, required: false
    end

    class CreateSiteAddressAttributes < Types::BaseInputObject
      argument :apartments_count, Int, required: true
      argument :name, String, required: false
      argument :move_in_starts_on, GraphQL::Types::ISO8601DateTime, required: true
      argument :address, CreateProjectAddressAttributes, required: false
    end

    class CreateProjectAttributes < Types::BaseInputObject
      argument :internal_id, ID, required: false
      argument :os_id, ID, required: false
      argument :name, String, required: true
      argument :status, String, required: false
      argument :description, String, required: false
      argument :additional_info, String, required: false
      argument :coordinate_east, Float, required: false
      argument :coordinate_north, Float, required: false

      argument :assignee_id, ID, required: false
      argument :lot_number, String, required: false
      argument :buildings_count, Int, required: true

      argument :building_type, String, required: false
      argument :construction_type, String, required: false
      argument :move_in_starts_on, GraphQL::Types::ISO8601DateTime, required: false
      argument :move_in_ends_on, GraphQL::Types::ISO8601DateTime, required: false
      argument :construction_starts_on, GraphQL::Types::ISO8601DateTime, required: false

      argument :address, CreateProjectAddressAttributes, required: false, as: :address_attributes
      argument :site_address, [CreateSiteAddressAttributes], required: false
      argument :address_books, [CreateProjectAddressBookAttributes], required: true, as: :address_books_attributes
    end

    argument :attributes, CreateProjectAttributes, required: true
    field :project, Types::ProjectType, null: true

    def resolve(attributes:)
      super(::Projects::Creator, :project, attributes: attributes.to_h)
    end
  end
end
