# frozen_string_literal: true

class BuildingsImporter < EtlBase
  SHEET_INDEX = 0
  SKIP_ROWS = 7

  ATTRIBUTE_MAPPINGS = FileParser.parse { 'etl/buildings/attribute_mappings.yml' }.freeze

  # Imports buildings from the excel.
  #
  # @param current_user [User] the user that initiated the action
  # @param input [File] the file upload
  #
  def call(current_user:, input:)
    sheet = Xsv::Workbook.open(file_path(input)).sheets[SHEET_INDEX]
    sheet.row_skip = SKIP_ROWS

    import(current_user, sheet)
  end

  private

  def import(current_user, sheet)
    super do
      Kiba.parse do
        source Buildings::Source, sheet: sheet
        errors = []

        # Update buildings with matching IDs in both excel & portal
        transform Buildings::TransformIdable, errors: errors

        # Update buildings with matching addresses in both excel & portal
        transform Buildings::TransformAddressable, errors: errors

        # Delete surplus buildings from the portal if excel has fewer buildings
        # or create new buildings in the portal if excel has extra buildings.
        transform Buildings::TransformSurplus, errors: errors
      end
    end
  end
end
