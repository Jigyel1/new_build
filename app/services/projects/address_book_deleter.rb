# frozen_string_literal: true

module Projects
  class AddressBookDeleter < BaseService
    include AddressBookHelper
    set_callback :call, :before, :validate!

    def call
      authorize! address_book.project, to: :update?

      with_tracking do
        address_book.destroy!
      end
    end

    private

    def validate!
      address_book.investor? && raise('Cnannnd')
    end

    def activity_params
      {
        action: :address_book_deleted,
        owner: current_user,
        trackable: address_book,
        parameters: { project_name: address_book.project_name, address_book_type: address_book.type }
      }
    end
  end
end
