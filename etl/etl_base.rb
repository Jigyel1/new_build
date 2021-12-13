# frozen_string_literal: true

class EtlBase
  include EtlHelper

  def self.call(input:, current_user: nil)
    new.call(input: input, current_user: current_user)
  end

  private

  def import(_current_user, _sheet)
    Kiba.run(yield)
  end
end
