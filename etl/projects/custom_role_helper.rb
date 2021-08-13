# frozen_string_literal: true

module Projects
  module CustomRoleHelper
    private

    def execute?
      display_name.present?
    end

    def row_mappings(*type)
      type = type.is_a?(Array) ? type : [type]
      ProjectImporter::ATTRIBUTE_MAPPINGS.dig(*type)
    end

    def assign_attributes
      attributes = row_mappings(type).except(:type)
      address_book.assign_attributes(attributes_hash(attributes))
      super
    end

    def address_book
      @_address_book ||= project.address_books.find_or_initialize_by(
        type: :others,
        display_name: display_name
      )
    end

    def display_name
      @_display_name ||= row[row_mappings(type, :type)]
    end
  end
end
