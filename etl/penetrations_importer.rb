# frozen_string_literal: true

class PenetrationsImporter < EtlBase
  SHEET_INDEX = 0
  SKIP_ROWS = 1
  ZIP = 0

  # Imports penetration details from the excel.
  #
  # @param current_user [User] the user that initiated the action
  # @param input [Pathname] the path to the excel to be imported
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
        errors = []
        source Penetrations::Source, sheet: sheet
        transform Penetrations::Transform
        destination Penetrations::Destination, errors

        post_process do
          PenetrationMailer.notify_import(current_user.id, errors).deliver_later if errors.present?
        end
      end
    end
  end
end
