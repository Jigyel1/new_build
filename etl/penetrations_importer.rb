# frozen_string_literal: true

class PenetrationsImporter < EtlBase
  attr_accessor :duplicate_zip, :sheets

  SHEET_INDEX = 0
  SKIP_ROWS = 1
  ZIP = 0

  # Imports penetration details from the excel.
  #
  # @param current_user [User] the user that initiated the action
  # @param input [Pathname] the path to the excel to be imported
  #
  def call(current_user:, input:)
    sheet = Xsv::Workbook.open(file_path(input)).sheets[ProjectsImporter::SHEET_INDEX]
    sheet.row_skip = ProjectsImporter::SKIP_ROWS
    @duplicate_zip, @sheets = [], []

    register_duplicate_entry(sheet)
    import(current_user, sheets, duplicate_zip)
  end

  private

  def import(current_user, sheet, duplicate_zip) # rubocop:disable Metrics/SeliseMethodLength
    super do
      Kiba.parse do
        errors = []
        source Penetrations::Source, sheet: sheet
        transform Penetrations::Transform
        destination Penetrations::Destination, errors

        post_process do
          if duplicate_zip.present?
            duplicate_zip.each { |index| errors << I18n.t('activerecord.admin_toolkit/penetration.exists', zip: index) }
          end

          PenetrationMailer.notify_import(current_user.id, errors).deliver_later if errors.present?
        end
      end
    end
  end

  def register_duplicate_entry(sheet) # rubocop:disable Metrics/AbcSize
    penetration = AdminToolkit::Penetration
    sheet.to_a.group_by { |i| i[0] }.each_pair do |key, value|
      value.count > 1 ? duplicate_zip << key : sheets << value[0]
      penetration.find_by(zip: key).destroy if value.count == 1 && penetration.find_by(zip: key).present?
    end
  end
end
