# frozen_string_literal: true

module Users
  class StatusUpdater < BaseService
    include UserFinder

    # By default .with_meta wraps the block into a DB transaction.
    # That could lead to an unexpected behavior, especially, when using .with_meta within an around_action.
    # To avoid wrapping the block into a DB transaction use transactional: false option.
    def call
      # Logidze.with_responsible(responsible_id: current_user.id)
      Logidze.with_meta(meta_tags, transactional: false) do
        authorize! current_user, to: :update_status?, with: UserPolicy

        user.update!(active: attributes[:active])
      end
    end

    private

    def meta_tags
      {
        users: {
          acted_on: {

          }
        }
      }
      # {
      #   users: [
      #     by: {
      #       id: user.id,
      #       action_type: :to,
      #       email: user.email
      #     },
      #     to: {
      #       id: current_user.id,
      #       action_type: :by,
      #       email: current_user.email
      #     }
      #   ]
      # }
    end
  end
end
