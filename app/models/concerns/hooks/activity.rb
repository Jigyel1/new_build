# frozen_string_literal: true

module Hooks
  module Activity
    extend ActiveSupport::Concern

    included do
      before_create :update_default_attributes
    end

    private

    def update_default_attributes
      return if %w[building_imported project_imported].include? action

      self.project_id = trackable.project_nr if trackable_type == 'Project'
      self.os_id = trackable.external_id if trackable_type == 'Projects::Building'
    end
  end
end
