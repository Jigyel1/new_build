# frozen_string_literal: true

module AdminToolkit
  class KamMappingUpdater < BaseService
    include KamMappingFinder
    set_callback :call, :before, :validate!

    def call
      authorize! kam_mapping, to: :update?, with: AdminToolkitPolicy

      super do
        with_tracking(activity_id = SecureRandom.uuid) do
          kam_mapping.update!(attributes)
          Activities::ActivityCreator.new(activity_params(activity_id)).call
        end
      end
    end

    private

    # Validate if the User with id `kam_id` is a KAM
    def validate!
      return if attributes[:kam_id].blank? || User.find(attributes[:kam_id]).kam?

      raise t('admin_toolkit.invalid_kam')
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :kam_mapping_updated,
        owner: current_user,
        recipient: kam_mapping.kam,
        trackable: kam_mapping,
        parameters: attributes.except(:id)
      }
    end
  end
end
