# frozen_string_literal: true

module Users
  class UserUpdater < BaseService
    include ActivityHelper
    include UserFinder

    set_callback :call, :before, :association_changed?

    def call
      authorize! user, to: :update?, with: UserPolicy

      user.assign_attributes(attributes)
      with_tracking(create_activity: association_changed?) do
        super { user.save! }
      end
    end

    private

    def activity_params
      super(:profile_updated)
    end

    def association_changed?
      @association_changed ||= user.profile.changed? || user.address.changed?
    end
  end
end
