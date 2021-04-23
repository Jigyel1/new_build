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

      permissions.each_pair do |resource, actions|
        permission = role.permissions.find_by(resource: resource)
        permission ? update(actions, permission) : create(resource, actions)
      end
    end

    private

    def permissions
      Role::PERMISSIONS[role.name]
    end

    def create(resource, actions)
      Permission.create!(
        resource: resource,
        actions: actions.each_with_object({}) { |item, hash| hash[item] = true },
        accessor: role
      )
    end

    def update(actions, policy)
      missing_keys = actions - policy.actions.keys
      policy.actions.merge!(missing_keys.each_with_object({}) { |item, hash| hash[item] = true })
      policy.save!
    end
  end
end
