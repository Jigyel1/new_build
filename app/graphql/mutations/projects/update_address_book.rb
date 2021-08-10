# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateAddressBook < BaseMutation
      class AddressAttributes < Types::BaseInputObject
        graphql_name 'UpdateAddressBookAddressAtttributes'

        include Concerns::Address
      end

      class UpdateAddressBookAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :type, String, required: false
        argument :name, String, required: false
        argument :display_name, String, required: false, description: <<~DESC
          For architect & investor, display name will be set the same as the type. If the type is
          others, display name will have a custom name and is REQUIRED!.
        DESC

        argument :additional_name, String, required: false
        argument :company, String, required: false
        argument :po_box, String, required: false
        argument :language, String, required: false
        argument :phone, String, required: false
        argument :mobile, String, required: false
        argument :email, String, required: false
        argument :website, String, required: false

        argument :address, AddressAttributes, as: :address_attributes, required: false
      end

      argument :attributes, UpdateAddressBookAttributes, required: true
      field :address_book, Types::Projects::AddressBookType, null: true

      def resolve(attributes:)
        resolver = ::Projects::AddressBookUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { address_book: resolver.address_book }
      end
    end
  end
end
