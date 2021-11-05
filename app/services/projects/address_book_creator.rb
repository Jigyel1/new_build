# frozen_string_literal: true

module Projects
  class AddressBookCreator < BaseService
    attr_reader :address_book

    def call
      authorize! project, to: :update?

      with_tracking do
        @address_book = project.address_books.build(attributes)
        address_book.entry_type = :manual
        address_book.save!
      end
    end

    private

    def project
      @_project ||= Project.find(attributes[:project_id])
    end

    def activity_params
      {
        action: :address_book_created,
        owner: current_user,
        trackable: address_book,
        parameters: { project_name: address_book.project_name, address_book_type: address_book.type }
      }
    end
  end
end
