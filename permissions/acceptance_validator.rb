# frozen_string_literal: true

module Permissions
  class AcceptanceValidator
    attr_accessor :resource, :accessor, :actions

    def initialize(record:, actions:)
      @resource = record.resource
      @accessor = record.accessor
      @actions = actions
    end

    def call
      return if invalid_keys.empty?

      raise StandardError, <<~MSG
        Action(s) #{invalid_keys.to_sentence} #{'is'.pluralize(invalid_keys.size)}
        not allowed for resource #{resource} of role #{accessor.name}
      MSG
    end

    private

    def invalid_keys
      (allowed_keys - Role::PERMISSIONS.dig(accessor.name, resource))
    rescue TypeError # raised whenever a resource is not defined for a given role in permissions.yml
      allowed_keys
    end

    def allowed_keys
      actions.select { |_key, value| value }.keys
    end
  end
end
