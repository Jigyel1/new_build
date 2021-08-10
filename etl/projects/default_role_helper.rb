module Projects
  module DefaultRoleHelper
    private

    def execute?
      external_id.present?
    end

    def external_id
      row[row_mappings(type, :external_id)]
    end

    def assign_attributes
      attributes = row_mappings(type)
      address_book.assign_attributes(attributes_hash(attributes))
    end

    def address_book
      @_address_book ||= project.address_books.find_or_initialize_by(type: type, display_name: type)
    end
  end
end
