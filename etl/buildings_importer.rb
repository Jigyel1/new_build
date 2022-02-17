# frozen_string_literal: true

class BuildingsImporter < EtlBase
  SHEET_INDEX = 0
  SKIP_ROWS = 1

  ATTRIBUTE_MAPPINGS = FileParser.parse { 'etl/buildings/attribute_mappings.yml' }.freeze

  # Imports buildings from the excel.
  #
  # @param current_user [User] the user that initiated the action
  # @param input [File] the file upload
  #
  def call(current_user:, input:)
    sheet = Xsv::Workbook.open(file_path(input)).sheets[SHEET_INDEX]
    sheet.row_skip = SKIP_ROWS

    import(current_user, sheet, nil)
  end

  private

  def import(current_user, sheet, _nil)
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

        post_process do
          ProjectMailer.notify_building_import(current_user.id, errors).deliver_later if errors.present?
        end
      end
    end
  end
end
