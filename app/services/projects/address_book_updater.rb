# frozen_string_literal: true

module Projects
  class AddressBookUpdater < BaseService
    include AddressBookHelper

    def call
      authorize! address_book.project, to: :update?

      with_tracking do
        address_book.assign_attributes(attributes)
        address_book.entry_type = :manual # even the ones that were initially from the `info_manager`
        address_book.save!
      end
    end

    private

    def activity_params
      {
        action: :address_book_updated,
        owner: current_user,
        trackable: address_book,
        parameters: { project_name: address_book.project_name, address_book_type: address_book.type }
      }
    end
  end
end
