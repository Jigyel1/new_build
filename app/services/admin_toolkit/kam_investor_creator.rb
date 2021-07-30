# frozen_string_literal: true

module AdminToolkit
  class KamInvestorCreator < BaseService
    attr_reader :kam_investor

    set_callback :call, :before, :validate!

    def call
      super do
        authorize! ::AdminToolkit::KamInvestor, to: :create?, with: AdminToolkitPolicy

        with_tracking(activity_id = SecureRandom.uuid) do
          @kam_investor = ::AdminToolkit::KamInvestor.create!(attributes)
          Activities::ActivityCreator.new(activity_params(activity_id)).call
        end
      end
    end

    private

    # Validate if the User with id `kam_id` is a KAM
    def validate!
      return if User.find(attributes[:kam_id]).kam?

      raise t('admin_toolkit.invalid_kam')
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :kam_investor_created,
        owner: current_user,
        recipient: kam_investor.kam,
        trackable: kam_investor,
        parameters: attributes
      }
    end
  end
end