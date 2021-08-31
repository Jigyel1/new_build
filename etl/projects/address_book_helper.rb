# frozen_string_literal: true

module Projects
  module AddressBookHelper
    prepend CustomAssigner

    def call
      super do
        assign_attributes
        assign_address_attributes
      end
    end

    private

    def assign_address_attributes
      attributes = row_mappings("#{type}_address")
      super(attributes_hash(attributes), address_book)
    end
  end
end
