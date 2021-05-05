# frozen_string_literal: true

module Users
  class StatusUpdater < BaseService
    include UserFinder

    # By default .with_meta wraps the block into a DB transaction.
    # That could lead to an unexpected behavior, especially, when using .with_meta within an around_action.
    # To avoid wrapping the block into a DB transaction use transactional: false option.
    # Above comment relevant when logidze is integrated. To be done in the next PR(#ActivityStream)
    def call
      authorize! current_user, to: :update_status?, with: UserPolicy

      transaction do
        user.update!(active: attributes[:active])
        current_user.activities.create!(
          recipient: user,
          verb: :status_updated,
          trackable_type: 'User',
          parameters: {
            active: attributes[:active]
          }
        )

        # Logidze.with_meta({ activity_id: activity.id }, transactional: false) do
        #   user.update!(active: attributes[:active])
        # end
      end
    end
  end
end
