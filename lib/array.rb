# frozen_string_literal: true

class Array
  def to_h
    super.with_indifferent_access
  end
end
