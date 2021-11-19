# frozen_string_literal: true

module Projects
  module Exports
    class PrepareBuildingRow < BaseService
      attr_accessor :project, :csv_headers, :building_project

      def call
        load_building_values
        load_building_project_values
        load_building_address_values

        # replace all commas with a space so that it does not screw-up the formatting.
        gsub_comma = ->(headers) { headers.to_s.tr(',', ' ') }
        values.flatten.map(&gsub_comma)
      end

      private

      def values
        @_values ||= []
      end

      def load_building_values
        values << csv_headers[:building].keys.map { |attr| setter { building.try(attr) } }
      end

      def load_building_project_values
        values << csv_headers[:building_project].keys.map { |attr| setter { building_project.try(attr) } }
      end

      def load_building_address_values
        values << csv_headers[:building_address].keys.map { |attr| setter { building_address.try(attr) } }
      end

      def setter
        yield || ''
      end
    end
  end
end
