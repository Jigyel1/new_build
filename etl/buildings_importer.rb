# frozen_string_literal: true

# REFERENCE - https://gist.github.com/thbar/ec90bbd5877d1aae40510fadd4320687

class BuildingsImporter < EtlBase
  SHEET_INDEX = 0
  SKIP_ROWS = 7

  ATTRIBUTE_MAPPINGS = FileParser.parse { 'etl/buildings/attribute_mappings.yml' }.freeze

  # Imports buildings from the excel.
  # When the input is the path to the file, i.e. String, replace the first line with
  #    #=> sheet = Xsv::Workbook.open(input).sheets[SHEET_INDEX]
  #
  # @param current_user [User] the user that initiated the action
  # @param input [File] the file upload
  #
  def call(current_user:, input:)
    sheet = Xsv::Workbook.open(input.tempfile.path).sheets[SHEET_INDEX]
    sheet.row_skip = SKIP_ROWS

    import(current_user, sheet)
  end

  private

  def import(current_user, sheet)
    super do
      Kiba.parse do
        source Buildings::Source, sheet: sheet
        errors = []

        transform Buildings::TransformIdable, errors
        transform Buildings::TransformAddressable, errors # Excel - Portal
        transform Buildings::TransformSurplus, errors # Portal - Excel
      end
    end
  end
end
