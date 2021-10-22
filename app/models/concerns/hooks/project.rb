# frozen_string_literal: true

module Hooks
  module Project
    extend ActiveSupport::Concern

    MANUALLY_CREATED = 'Manually Created'

    included do
      after_save :update_projects_list, :update_users_list
      after_destroy :update_projects_list, :update_users_list

      before_create :set_external_urls
      after_create :create_default_label_group
    end

    private

    def create_default_label_group
      label_group = label_groups.create!(system_generated: true)
      label_group.label_list << MANUALLY_CREATED if manual?
      label_group.save!
    end

    def set_external_urls
      self.gis_url = "#{Rails.application.config.gis_url}#{external_id}"
      self.info_manager_url = "#{Rails.application.config.info_manager_url}#{external_id}"
    end
  end
end
