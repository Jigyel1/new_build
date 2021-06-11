# frozen_string_literal: true

module Users
  class StatusUpdater < BaseService
    include UserFinder

    private

    def process
      authorize! user, to: :update_status?, with: UserPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        user.update!(active: attributes[:active])

        Activities::ActivityCreator.new(
          activity_params(activity_id, :status_updated, { active: attributes[:active] })
        ).call
      end
    end

    def execute?
      user.active != attributes.active
    end
  end
end
