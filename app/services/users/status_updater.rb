# frozen_string_literal: true

module Users
  class StatusUpdater < BaseService
    include ActivityHelper
    include UserFinder

    set_callback :call, :before, :status_changed?

    def call
      authorize! user, to: :update_status?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        user.assign_attributes(active: attributes[:active])
        super { user.save! }

        if status_changed?
          Activities::ActivityCreator.new(
            activity_params(activity_id, :status_updated, { active: attributes[:active] })
          ).call
        end
      end
    end

    private

    def status_changed?
      @status_changed ||= user.active_changed?
    end
  end
end
