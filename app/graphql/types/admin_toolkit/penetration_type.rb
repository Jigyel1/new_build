# frozen_string_literal: true

module Types
  module AdminToolkit
    class PenetrationType < BaseObject
      field :id, ID, null: true
      field :zip, String, null: true
      field :city, String, null: true
      field :rate, Float, null: true
      field :kam_region, KamRegionType, null: true
      field :hfc_footprint, Boolean, null: true
      field :type, String, null: true
      field :strategic_partner, String, null: true

      field(
        :penetration_competitions,
        [Types::AdminToolkit::PenetrationCompetitionType],
        null: true
      )

      def rate
        object.rate.percentage
      end
    end
  end
end
