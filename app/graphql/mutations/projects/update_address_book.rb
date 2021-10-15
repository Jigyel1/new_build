# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateAddressBook < BaseMutation
      class UpdateAddressBookAddressAttributes < Types::BaseInputObject
        include Concerns::Address
      end

      class UpdateAddressBookAttributes < Types::BaseInputObject
        include Concerns::AddressBook

        argument :id, ID, required: true
        argument :address, UpdateAddressBookAddressAttributes, as: :address_attributes, required: false
      end

      argument :attributes, UpdateAddressBookAttributes, required: true
      field :address_book, Types::Projects::AddressBookType, null: true

      def resolve(attributes:)
        super(::Projects::AddressBookUpdater, :address_book, attributes: attributes.to_h)
      end
    end
  end
end
