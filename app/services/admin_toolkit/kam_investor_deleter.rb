# frozen_string_literal: true

module AdminToolkit
  class KamInvestorDeleter < BaseService
    include KamInvestorFinder

    def call
      authorize! kam_investor, to: :destroy?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        kam_investor.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :kam_investor_deleted,
        owner: current_user,
        trackable: kam_investor,
        recipient: kam_investor.kam,
        parameters: kam_investor.attributes.slice('kam_id', 'investor_id')
      }
    end
  end
end
