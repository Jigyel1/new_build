# frozen_string_literal: true

module AdminToolkit
  class KamMappingDeleter < BaseService
    include KamMappingFinder

    private

    def process
      authorize! kam_mapping, to: :destroy?, with: AdminToolkitPolicy

      with_tracking(activity_id = SecureRandom.uuid) do
        kam_mapping.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def execute?
      true
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :kam_mapping_deleted,
        owner: current_user,
        trackable: kam_mapping,
        recipient: kam_mapping.kam,
        parameters: kam_mapping.attributes.slice('kam_id', 'investor_id')
      }
    end
  end
end
