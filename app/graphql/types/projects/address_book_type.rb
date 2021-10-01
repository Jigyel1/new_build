# frozen_string_literal: true

module Types
  module Projects
    class AddressBookType < BaseObject
      field :id, ID, null: false
      field :type, String, null: true
      field :name, String, null: true
      field :display_name, String, null: true
      field :additional_name, String, null: true
      field :company, String, null: true

      field :po_box, String, null: true
      field :language, String, null: true
      field :phone, String, null: true
      field :mobile, String, null: true
      field :email, String, null: true
      field :website, String, null: true
      field :entry_type, String, null: true

      field :address, Types::AddressType, null: true

      def address
        preload_association(:address)
      end
    end
  end
end
