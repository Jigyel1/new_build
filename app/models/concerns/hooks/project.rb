# frozen_string_literal: true

module Hooks
  module Project
    extend ActiveSupport::Concern

    MANUALLY_CREATED = 'Manually Created'

    included do
      before_save :set_kam_region
      before_create :set_external_urls, :set_competition
      after_save :update_projects_list, :update_users_list
      after_create :create_default_label_group, :update_status
      after_destroy :update_projects_list, :update_users_list
    end

    private

    def set_kam_region
      self.kam_region = AdminToolkit::Penetration.find_by(zip: zip).try(:kam_region)
    end

    def create_default_label_group
      label_group = label_groups.create!(system_generated: true)
      label_group.label_list << MANUALLY_CREATED if manual?
      label_group.save!
    end

    def update_status
      update(status: :archived) if irrelevant?
    end

    def set_external_urls
      self.gis_url = "#{Rails.application.config.gis_url}#{external_id}"
      self.info_manager_url = "#{Rails.application.config.info_manager_url}#{external_id}"
    end

    def set_competition
      self.competition ||= ::Projects::CompetitionSetter.new(project: self).call
    end
  end
end
