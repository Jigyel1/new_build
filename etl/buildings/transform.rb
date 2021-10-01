# frozen_string_literal: true

module Buildings
  class Transform
    extend Forwardable
    attr_reader :project, :organizer, :rows

    EXTERNAL_ID = 6
    APARTMENTS_COUNT = 15
    MOVE_IN_STARTS_ON = 22
    STREET = 7
    STREET_NO = 8
    BUILDING_NO = 9
    ZIP = 10
    CITY = 11

    ACCESSORS = %i[
      organizer idable_buildings idable_rows addressable_buildings addressable_rows ordered_buildings ordered_rows
    ].freeze
    def_delegators(*ACCESSORS)

    def initialize(errors)
      @errors = errors
    end

    protected

    def attributes_hash(row, attributes)
      attributes.keys.zip(row.values_at(*attributes.values)).to_h
    end

    def building_attributes(row)
      {
        apartments_count: row[APARTMENTS_COUNT].to_i,
        move_in_starts_on: row[MOVE_IN_STARTS_ON].try(:to_date),
        additional_details: attributes_hash(row, BuildingsImporter::ATTRIBUTE_MAPPINGS[:additional_details]),
        address_attributes: {
          street: row[STREET],
          city: row[CITY],
          zip: row[ZIP],
          street_no: "#{row[STREET_NO]} #{row[BUILDING_NO]}".squish
        }
      }
    end
  end
end
