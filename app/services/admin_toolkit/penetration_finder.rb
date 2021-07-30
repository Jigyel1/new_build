# frozen_string_literal: true

module AdminToolkit
  module PenetrationFinder
    def penetration
      @penetration ||= AdminToolkit::Penetration.find(attributes[:id])
    end
  end
end
