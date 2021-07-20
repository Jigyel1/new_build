# frozen_string_literal: true

module AdminToolkit
  module KamMappingFinder
    def kam_mapping
      @kam_mapping ||= AdminToolkit::KamMapping.find(attributes[:id])
    end
  end
end
