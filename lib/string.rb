# frozen_string_literal: true

class String
  def to_a_uniq(separator: ',')
    split(separator).map(&:squish).uniq
  end
end
