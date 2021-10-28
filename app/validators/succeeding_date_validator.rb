# frozen_string_literal: true

class SucceedingDateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, succeeding_date)
    preceding_date_key = options[:preceding_date_key]
    preceding_date = preceding_date_key && record.send(preceding_date_key)

    return unless preceding_date
    return if succeeding_date.after?(preceding_date)

    record.errors.add(attribute, I18n.t('date.errors.messages.must_be_after', date: preceding_date))
  end
end
