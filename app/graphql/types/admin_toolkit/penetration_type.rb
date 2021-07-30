# frozen_string_literal: true

module Types
  module AdminToolkit
    class PenetrationType < BaseObject
      field :id, ID, null: true
      field :zip, String, null: true
      field :city, String, null: true
      field :rate, String, null: true
      field :competition, CompetitionType, null: true
      field :kam_region, KamRegionType, null: true
      field :hfc_footprint, Boolean, null: true
      field :type, String, null: true

      def rate
        object.rate.rounded
      end
    end
  end
end
