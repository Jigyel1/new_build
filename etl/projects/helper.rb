# frozen_string_literal: true

module Projects
  module Helper
    extend Forwardable
    def_delegators :project, :row

    def row_mappings(*type)
      ProjectImporter::ATTRIBUTE_MAPPINGS.dig(*type)
    end

    def attributes_hash(attributes)
      attributes.keys.zip(row.values_at(*attributes.values)).to_h
    end

    def assign_address_attributes(attributes, addressable)
      # split the array between the last item and the rest.
      # eg. for street { "street"=>"Chemin du Taxroz 3A et 3B" }
      # street => ["Chemin", "du", "Taxroz", "3A", "et"] and street_no => 3B.
      # Then convert the street to a string with a join.
      #
      *street, street_no = attributes[:street].try(:split, ' ') || [nil, nil]
      addressable.build_address(
        attributes.merge(street: street.join(' '), street_no: street_no)
      )
    end
  end
end
