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

      Role::PERMISSIONS[role.name].each_pair do |resource, actions|
        permission = role.permissions.find_by(resource: resource)
        permission ? update(actions, permission) : create(resource, actions)
      end
    end

    private

    def create(resource, actions)
      Permission.create!(
        resource: resource,
        actions: actions.index_with { |_item| true },
        accessor: role
      )
    end

    def update(actions, policy)
      missing_keys = actions - policy.actions.keys
      policy.actions.merge!(missing_keys.index_with { |_item| true })
      policy.save!
    end
  end
end
