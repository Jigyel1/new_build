# frozen_string_literal: true

require_relative '../../app/models/admin_toolkit/penetration'

module Penetrations
  class Destination
    def write(row)
      penetration = AdminToolkit::Penetration.find_or_initialize_by(zip: row.delete(:zip))
      penetration.assign_attributes(row)
      penetration.save!
    end
  end
end
