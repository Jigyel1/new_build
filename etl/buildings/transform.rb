# frozen_string_literal: true

module Buildings
  class Transform
    extend Forwardable
    attr_reader :project, :organizer, :rows

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
  end
end
