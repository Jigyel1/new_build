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
        resolver = ::Projects::AddressBookUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { address_book: resolver.address_book }
      end
    end
  end
end
