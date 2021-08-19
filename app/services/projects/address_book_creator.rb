# frozen_string_literal: true

module Projects
  class AddressBookCreator < BaseService
    attr_reader :project, :address_book

    def call
      authorize! project, to: :create?, with: ProjectPolicy
      with_tracking(activity_id = SecureRandom.uuid) do
        @address_book = project.address_books.build(attributes)
        address_book.entry_type = :manual
        address_book.save!
        # Activities::ActivityCreator.new(activity_params(activity_id)).call
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
        parameters: attributes
      }
    end
  end
end
