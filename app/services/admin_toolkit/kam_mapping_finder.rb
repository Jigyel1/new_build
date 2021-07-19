module AdminToolkit
  module KamMappingFinder
    def kam_mapping
      @_kam_mapping ||= AdminToolkit::KamMapping.find(attributes[:id])
    end
  end
end