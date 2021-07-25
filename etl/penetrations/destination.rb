# frozen_string_literal: true

module Penetrations
  class Destination
    def write(row)
      penetration = AdminToolkit::Penetration.find_or_initialize_by(zip: row.delete(:zip))
      penetration.assign_attributes(row)
      penetration.save!
    end
  end
end
