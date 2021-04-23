# frozen_string_literal: true

module Permissions
  class AcceptanceValidator
    include Assigner
    attr_accessor :resource, :accessor, :keys

    def initialize(attributes = {})
      assign_attributes(attributes)
    end

    def call
      return if invalid_keys.empty?

      raise StandardError, <<~MSG
        Action(s) #{invalid_keys.to_sentence} #{'is'.pluralize(invalid_keys.size)}
        not valid for resource #{resource} of role #{accessor.name}
      MSG
    end

    private

    def invalid_keys
      (keys - Role::PERMISSIONS.dig(accessor.name, resource))
    rescue TypeError # raised whenever a resource is not defined for a given role in permissions.yml
      keys
    end
  end
end
