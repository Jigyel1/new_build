# frozen_string_literal: true

module AdminToolkit
  class PctValuesUpdater < BaseService
    def call
      authorize! ::AdminToolkit::PctValue, to: :update?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid, transaction: true) do
        attributes.each { |hash| ::AdminToolkit::PctValue.find(hash[:id]).update!(hash) }
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      values = ::AdminToolkit::PctValue.find(attributes.dig(0, :id))
      {
        activity_id: activity_id,
        action: :pct_value_updated,
        owner: current_user,
        trackable: values,
        parameters: { min: values.pct_month.min, max: values.pct_month.max,
                      min_cost: values.pct_cost.min, max_cost: values.pct_cost.max, status: values.status }
      }
    end
  end
end
