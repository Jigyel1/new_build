# frozen_string_literal: true

module Projects
  module Exports
    class PrepareBuildingHeaders < BaseService
      attr_accessor :csv_headers, :building, :building_project

      def call
        %i[building].each { |type| send("load_#{type}_headers") }
        headers.flatten
      end

      private

      def headers
        @_headers ||= []
      end

      def load_building_headers
        %i[building_project building building_address].each do |type|
          headers << csv_headers[type].values
        end
      end
    end
  end
end
