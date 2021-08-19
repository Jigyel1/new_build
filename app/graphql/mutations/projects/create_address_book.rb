# frozen_string_literal: true

module Mutations
  module Projects
    class CreateAddressBook < BaseMutation
      class CreateAddressBookAddressAttributes < Types::BaseInputObject
        argument :street, String, required: true
        argument :street_no, String, required: true
        argument :city, String, required: true
        argument :zip, String, required: true
      end

      class CreateAddressBookAttributes < Types::BaseInputObject
        include Concerns::AddressBook

        argument :project_id, ID, required: true
        argument :type, String, required: true
        argument :name, String, required: true
        argument :phone, String, required: true

        argument :address, CreateAddressBookAddressAttributes, as: :address_attributes, required: false
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
