# frozen_string_literal: true

module AdminToolkit
  class KamInvestorUpdater < BaseService
    include KamInvestorFinder
    set_callback :call, :before, :validate!

    def call
      authorize! kam_investor, to: :update?, with: AdminToolkitPolicy

      super do
        with_tracking { kam_investor.update!(attributes) }
      end
    end

    private

    # Validate if the User with id `kam_id` is a KAM
    def validate!
      return if attributes[:kam_id].blank? || User.find(attributes[:kam_id]).kam?

      raise t('admin_toolkit.invalid_kam')
    end

    def activity_params
      {
        action: :kam_investor_updated,
        owner: current_user,
        recipient: kam_investor.kam,
        trackable: kam_investor,
        parameters: attributes.except(:id)
      }
    end
  end
end
