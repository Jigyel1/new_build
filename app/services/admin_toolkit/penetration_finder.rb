module AdminToolkit
  module PenetrationFinder
    def penetration
      @_penetration ||= AdminToolkit::Penetration.find(attributes[:id])
    end
  end
end