# frozen_string_literal: true

module Penetrations
  class Destination
    def write(penetration)
      penetration.save!
    end
  end
end
