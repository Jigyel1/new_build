# frozen_string_literal: true

require_relative '../../permissions/acceptance_validator'

class PermissionActionsValidator < ActiveModel::EachValidator
  def validate_each(record, _attr, value)
    return if record.resource.blank? || record.accessor.nil?

    Permissions::AcceptanceValidator.new(record: record, actions: value).call
  end
end
