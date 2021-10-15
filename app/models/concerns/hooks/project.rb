# frozen_string_literal: true

module Hooks
  module Project
    extend ActiveSupport::Concern

    MANUALLY_CREATED = 'Manually Created'

    included do
      after_save :update_projects_list, :update_users_list
      after_create :create_default_label_group
      after_destroy :update_projects_list, :update_users_list
    end

    private

    def create_default_label_group
      label_group = label_groups.create!(system_generated: true)
      label_group.label_list << MANUALLY_CREATED if manual?
      label_group.save!
    end
  end
end
