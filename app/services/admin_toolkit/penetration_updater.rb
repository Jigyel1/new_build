# frozen_string_literal: true

module AdminToolkit
  class PenetrationUpdater < BaseService
    include PenetrationFinder
    set_callback :call, :before, :format_attributes

    def call
      authorize! penetration, to: :update?, with: AdminToolkitPolicy

      with_tracking do
        with_uniqueness_check(:competition) do
          super { penetration.update!(attributes) }
        end
      end
    end

    private

    def format_attributes
      attributes[:rate] = attributes[:rate] / 100 if attributes[:rate]
      attributes
    end

    def activity_params
      {
        action: :penetration_updated,
        owner: current_user,
        trackable: penetration,
        parameters: attributes.except(:id)
      }
    end
  end
end
