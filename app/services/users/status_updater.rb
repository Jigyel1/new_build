# frozen_string_literal: true

module Users
  class StatusUpdater < BaseService
    include ActivityHelper
    include UserFinder

    set_callback :call, :before, :status_changed?

    def call
      authorize! user, to: :update_status?, with: UserPolicy

      user.assign_attributes(active: attributes[:active])
      with_tracking(create_activity: status_changed?) do
        super { user.save! }
      end
    end

    private

    def activity_params
      super(:status_updated, { active: attributes[:active] })
    end

    def status_changed?
      @status_changed ||= user.active_changed?
    end
  end
end
