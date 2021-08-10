module Projects
  module AddressBookHelper
    def call
      super do
        assign_attributes
        assign_address_attributes
        assign_additional_details
      end
    end

    private

    def assign_address_attributes
      attributes = row_mappings("#{type}_address")
      super(attributes_hash(attributes), address_book)
    end

    def assign_additional_details
      attributes = row_mappings("#{type}_additional_details")
      address_book.additional_details = attributes_hash(attributes)
    end
  end
end
