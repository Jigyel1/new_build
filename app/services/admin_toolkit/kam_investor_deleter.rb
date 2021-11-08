# frozen_string_literal: true

module AdminToolkit
  class KamInvestorDeleter < BaseService
    include KamInvestorFinder

    def call
      authorize! kam_investor, to: :destroy?, with: AdminToolkitPolicy

      with_tracking { kam_investor.destroy! }
    end

    private

    def activity_params
      {
        action: :kam_investor_deleted,
        owner: current_user,
        trackable: kam_investor,
        recipient: kam_investor.kam,
        parameters: kam_investor.attributes.slice('kam_id', 'investor_id')
      }
    end
  end
end
