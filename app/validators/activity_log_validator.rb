# frozen_string_literal: true

class ActivityLogValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    case record.verb
    when 'status_updated'
      !value.dig('parameters', 'active').nil? || record.errors.add(:log_data, :active_flag_blank)
    when 'role_updated'
      value.dig('parameters', 'role').present? || record.errors.add(:log_data, :role_blank)
    end
  end
end
