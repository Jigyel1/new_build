# frozen_string_literal: true

module Users
  class StatusUpdater < BaseService
    include UserFinder

    def call
      authorize! current_user, to: :update_status?, with: UserPolicy

      track_update(activity_id = SecureRandom.uuid) do
        user.update!(active: attributes[:active])

        ActivityPopulator.new(
          activity_params(activity_id, :status_updated, { active: attributes[:active] })
        ).call
      end
    end
  end
end
