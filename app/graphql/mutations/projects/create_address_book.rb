# frozen_string_literal: true

module Mutations
  module Projects
    class CreateAddressBook < BaseMutation
      class AddressAttributes < Types::BaseInputObject
        graphql_name 'CreateAddressBookAddressAtttributes'

        argument :street, String, required: true
        argument :street_no, String, required: true
        argument :city, String, required: true
        argument :zip, String, required: true
      end

      class CreateAddressBookAttributes < Types::BaseInputObject
        argument :project_id, ID, required: true
        argument :type, String, required: true
        argument :name, String, required: true
        argument :display_name, String, required: false, description: <<~DESC
          For architect & investor, display name will be set the same as the type. If the type is
          others, display name will have a custom name and is REQUIRED!.
        DESC

        argument :additional_name, String, required: false
        argument :company, String, required: false
        argument :po_box, String, required: false
        argument :language, String, required: false
        argument :phone, String, required: true
        argument :mobile, String, required: false
        argument :email, String, required: false
        argument :website, String, required: false

        argument :address, AddressAttributes, as: :address_attributes, required: false
      end

      argument :attributes, CreateAddressBookAttributes, required: true
      field :address_book, Types::Projects::AddressBookType, null: true

      def resolve(attributes:)
        resolver = ::Projects::AddressBookCreator.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { address_book: resolver.address_book }
      end
    end
  end
end
