# frozen_string_literal: true

module AdminToolkit
  class KamMappingCreator < BaseService
    attr_reader :kam_mapping

    set_callback :call, :before, :validate!

    def call
      super do
        authorize! ::AdminToolkit::KamMapping, to: :create?, with: AdminToolkitPolicy

        with_tracking(activity_id = SecureRandom.uuid) do
          @kam_mapping = ::AdminToolkit::KamMapping.create!(attributes)
          Activities::ActivityCreator.new(activity_params(activity_id)).call
        end
      end
    end

    private

    # Validate if the User with id `kam_id` is a KAM
    def validate!
      return if User.find(attributes[:kam_id]).kam?

      raise t('admin_toolkit.kam_mapping.invalid_kam')
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :kam_mapping_created,
        owner: current_user,
        recipient: kam_mapping.kam,
        trackable: kam_mapping,
        parameters: attributes
      }
    end
  end
end
