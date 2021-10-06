# frozen_string_literal: true

class LabelListValidator < ActiveModel::EachValidator
  def validate_each(record, _attribute, value)
    return if processed(value).uniq == processed(value)

    record.errors.add(:base, :labels_not_unique)
  end

  private

  def processed(array)
    array.map(&:squish).map(&:downcase).sort
  end
end
