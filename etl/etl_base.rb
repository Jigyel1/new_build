# frozen_string_literal: true

class EtlBase
  def self.call(input:, current_user: nil)
    new.call(current_user: current_user, input: input)
  end

  private

  def import(_current_user, _sheet)
    Kiba.run(yield)
  end
end
