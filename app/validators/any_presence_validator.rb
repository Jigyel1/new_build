# frozen_string_literal: true

# Use this validator to validate that at least one of the fields is present for a given
# model.
class AnyPresenceValidator < ActiveModel::Validator
  def validate(record)
    return if options[:fields].any? { |field| record.send(field).present? }

    words_connector = { two_words_connector: ' or ', last_word_connector: ', or ' }
    record.errors.add(
      :base,
      I18n.t('any_presence', fields: options[:fields].to_sentence(**words_connector))
    )
  end
end
