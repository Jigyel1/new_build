# frozen_string_literal: true

class ProjectsImporter < EtlBase
  SHEET_INDEX = 0
  SKIP_ROWS = 1
  EXTERNAL_ID = 0

  ATTRIBUTE_MAPPINGS = FileParser.parse { 'etl/projects/attribute_mappings.yml' }.freeze

  # Imports projects from the excel.
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

  def import(current_user, sheet) # rubocop:disable Metrics/SeliseMethodLength
    super do
      Kiba.parse do
        # TODO: pre_process to confirm excel format and raise if not valid!

        source Projects::Source, sheet: sheet

        errors = []
        transform Projects::TransformProject, errors

        transform Projects::TransformAddressBook, :investor
        transform Projects::TransformAddressBook, :architect
        transform Projects::TransformAddressBook, :role_type_3
        transform Projects::TransformAddressBook, :role_type_4

        destination Projects::Destination, errors

        post_process do
          ProjectMailer.notify_import(current_user.id, errors).deliver_later if errors.present?
        end
      end
    end
  end
end
