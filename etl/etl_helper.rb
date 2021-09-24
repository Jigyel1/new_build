# frozen_string_literal: true

module EtlHelper
  def to_int(row)
    self.class::TO_INTS.each do |index|
      value = row[index]
      next if value.blank?

      row[index] = row[index].to_i
    end
  end
end
