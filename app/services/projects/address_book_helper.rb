# frozen_string_literal: true

module Projects
  module AddressBookHelper
    def address_book
      @address_book ||= Projects::AddressBook.find(attributes.delete(:id))
    end
  end
end
