# frozen_string_literal: true

module AdminToolkit
  class CostThresholdUpdater < BaseService
    def cost_threshold
      @cost_threshold ||= AdminToolkit::CostThreshold.find(attributes[:id])
    end

    def call
      authorize! cost_threshold, to: :update?, with: AdminToolkitPolicy

      cost_threshold.update!(attributes)
    end

    private

    # @todo - Activity log to be implemented in upcoming PR

    def activity_params
      {
        action: :cost_threshold_updated,
        owner: current_user,
        trackable: cost_threshold,
        parameters: attributes.except(:id)
      }
    end
  end
end
