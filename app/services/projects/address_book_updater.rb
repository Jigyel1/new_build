# frozen_string_literal: true

module Projects
  class AddressBookUpdater < BaseService
    attr_reader :address_book

    def call
      authorize! address_book.project, to: :update?, with: ProjectPolicy
      with_tracking(activity_id = SecureRandom.uuid) do
        address_book.assign_attributes(attributes)
        address_book.entry_type = :manual # even the ones that were initially `info_manager`
        address_book.save!
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def address_book
      @_address_book ||= AddressBook.find(attributes.delete(:id))
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :address_book_updated,
        owner: current_user,
        trackable: address_book,
        parameters: attributes
      }
    end
  end
end
