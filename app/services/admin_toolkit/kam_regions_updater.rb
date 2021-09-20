# frozen_string_literal: true

module AdminToolkit
  class KamRegionsUpdater < BaseService
    set_callback :call, :before, :validate!

    def call
      authorize! ::AdminToolkit::KamRegion, to: :update?, with: AdminToolkitPolicy

      super do
        with_tracking(activity_id = SecureRandom.uuid, transaction: true) do
          attributes.each { |hash| ::AdminToolkit::KamRegion.find(hash[:id]).update!(hash) }
          Activities::ActivityCreator.new(activity_params(activity_id)).call
        end
      end
    end

    private

    # Validate if all `kam_ids` are actually KAMs
    def validate!
      # Reject blank/nil kam_ids as FE may send those to un assign a KAM.
      # You don't query DB with nil kam id.
      kam_ids = attributes.pluck(:kam_id).reject(&:blank?)
      return if kam_ids.all? { |kam_id| User.find(kam_id).kam? }

      raise t('admin_toolkit.invalid_kam')
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :kam_region_updated,
        owner: current_user,
        trackable: ::AdminToolkit::KamRegion.find(attributes.dig(0, :id))
      }
    end
  end
end
