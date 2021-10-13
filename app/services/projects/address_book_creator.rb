# frozen_string_literal: true

module Projects
  class AddressBookCreator < BaseService
    attr_reader :address_book

    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        @address_book = project.address_books.build(attributes)
        address_book.entry_type = :manual
        address_book.save!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def project
      @_project ||= Project.find(attributes[:project_id])
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :address_book_created,
        owner: current_user,
        trackable: address_book,
        parameters: {
          project_name: address_book.project_name,
          address_book_type: address_book.type
        }
      }
    end
  end
end
