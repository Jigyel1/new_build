# frozen_string_literal: true

module Projects
  class BasePopulator
    extend Forwardable
    def_delegators :project, :row

    attr_reader :project, :type

    def initialize(project, type: nil)
      @project = project
      @type = type
    end

    def call
      yield if execute?

      project
    end

    protected

    def row_mappings(*type)
      ProjectsImporter::ATTRIBUTE_MAPPINGS.dig(*type)
    end

    def attributes_hash(attributes)
      attributes.keys.zip(row.values_at(*attributes.values)).to_h
    end

    # split the array between the last item and the rest.
    # if <tt>attributes[:street]</tt> ends with a number, save the number as street_no
    # and the prefix as the street. Otherwise, take the whole string as the street.
    #
    # eg. for
    #   attributes[:street] = { "street"=>"Chemin du Taxroz 3A et 30" }
    #   street => "Chemin du Taxroz 3A et" and street_no => 30.
    #
    #   attributes[:street] = { "street"=>"Chemin du Taxroz 3A et 3B" }
    #   street => "Chemin du Taxroz 3A et 3B" and street_no => nil
    #
    #   attributes[:street] = { "street" => "45" }
    #   street => "45" and street_no => nil
    def assign_address_attributes(attributes, addressable)
      *street, street_no = attributes[:street].try(:split, ' ')

      addressable.build_address(
        if street && street_no.try(:match?, /\d+/)
          attributes.merge(street: street.join(' '), street_no: street_no)
        else
          attributes
        end
      )
    end
  end
end
