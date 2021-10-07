# frozen_string_literal: true

module Types
  module AdminToolkit
    class FootprintValueType < BaseObject
      field :id, ID, null: true
      field :category, String, null: true
      field :footprint_apartment, FootprintApartmentType, null: true
      field :footprint_type, FootprintTypeType, null: true

      def footprint_apartment
        preload_association(:footprint_apartment)
      end

      def footprint_type
        preload_association(:footprint_type)
      end
    end
  end
end
