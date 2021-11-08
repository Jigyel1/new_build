# frozen_string_literal: true

module AdminToolkit
  class PctValuesUpdater < BaseService
    def call
      authorize! ::AdminToolkit::PctValue, to: :update?, with: AdminToolkitPolicy

      with_tracking(transaction: true) do
        attributes.each { |hash| ::AdminToolkit::PctValue.find(hash[:id]).update!(hash) }
      end
    end

    private

    def activity_params
      {
        action: :pct_value_updated,
        owner: current_user,
        trackable: ::AdminToolkit::PctValue.find(attributes.dig(0, :id))
      }
    end
  end
end
