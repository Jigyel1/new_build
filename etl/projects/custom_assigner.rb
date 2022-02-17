# frozen_string_literal: true

module Projects
  module CustomAssigner
    # This method will be called after the attributes for the given address books are assigned.
    # Any additional formatting of the address book attributes after assignment can be added here.
    def assign_attributes
      # For address books where external_ids start with 'c', set those as the main contact for
      # the project and remove 'c' and save the `external_id`.
      main_contact, external_id = if address_book.external_id.present?
                                    [true, address_book.external_id]
                                  else
                                    [false, address_book.external_id]
                                  end

      # `to_i` otherwise the value will be saved with a decimal.
      # eg. '109933.0' => '109933'
      address_book.assign_attributes(
        main_contact: main_contact,
        external_id: external_id.to_i,
        entry_type: :info_manager
      )
    end
  end
end
