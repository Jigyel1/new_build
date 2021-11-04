# frozen_string_literal: true

module AdminToolkit
  class FootprintValuesUpdater < BaseService
    def call
      authorize! ::AdminToolkit::FootprintValue, to: :update?, with: AdminToolkitPolicy

      with_tracking(transaction: true) do
        attributes.each { |hash| ::AdminToolkit::FootprintValue.find(hash[:id]).update!(hash) }
      end
    end

    private

    def activity_params
      {
        action: :footprint_value_updated,
        owner: current_user,
        trackable: ::AdminToolkit::FootprintValue.find_by(id: attributes.dig(0, :id))
      }
    end
  end
end
