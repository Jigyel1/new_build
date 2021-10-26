# frozen_string_literal: true

class Float
  def rounded
    round(2)
  end

  def percentage
    (self * 100).rounded
  end
end
