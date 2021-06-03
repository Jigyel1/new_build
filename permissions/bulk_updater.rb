# frozen_string_literal: true

module Permissions
  class BulkUpdater
    include Assigner
    attr_accessor :role

    def initialize(attributes = {})
      assign_attributes(attributes)
    end

    def call
      raise StandardError, I18n.t('permission.role_only') unless role.is_a?(Role)

      seed_default!
      update_permission!
    end

    private

    def seed_default!
      Rails.application.config.available_permissions.each_pair do |resource, actions|
        permission = role.permissions.find_or_create_by!(resource: resource)
        permission.update!(actions: actions.index_with { |_item| false })
      end
    end

    def update_permission!
      Rails.application.config.role_permissions[role.name].each_pair do |resource, actions|
        role.permissions.find_by!(resource: resource).update!(actions: actions.index_with { |_item| true })
      end
    end
  end
end
