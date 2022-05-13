# frozen_string_literal: true

module Hooks
  module Activity
    extend ActiveSupport::Concern

    included do
      before_create :update_default_attributes
    end

    private

    def update_default_attributes # rubocop:disable Metrics/AbcSize
      return if %w[building_imported project_imported].include?(action)

      self.project_id = trackable.try(:project_nr) if trackable_type.eql?('Project')
      self.project_external_id = trackable.external_id if trackable_type.eql?('Project')
      self.os_id = trackable.try(:external_id) if trackable_type.eql?('Projects::Building')
    end
  end
end
