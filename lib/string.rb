# frozen_string_literal: true

class String
  def to_a_uniq(separator: ',')
    split(separator).map(&:squish).uniq
  end

  def to_b
    ActiveModel::Type::Boolean.new.cast(self)
  end
end
