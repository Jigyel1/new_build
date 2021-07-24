# frozen_string_literal: true

module Users
  class UserUpdater < BaseService
    include UserFinder

    set_callback :call, :before, :attributes_changed?

    def call
      authorize! user, to: :update?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        user.assign_attributes(attributes)
        super { user.save! }

        if attributes_changed?
          Activities::ActivityCreator.new(
            activity_params(activity_id, :profile_updated, attributes)
          ).call
        end
      end
    end

    private

    def attributes_changed?
      @attributes_changed ||= user.profile.changed? || user.address.changed?
    end
  end
end
