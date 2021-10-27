# frozen_string_literal: true

class EndDateValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, move_in_ends_on)
    return unless record.move_in_starts_on
    return if move_in_ends_on.after?(record.move_in_starts_on)

    record.errors.add(:move_in_ends_on, I18n.t('date.errors.messages.must_be_after', date: record.move_in_starts_on))
  end
end
