# frozen_string_literal: true

class ProjectImporter < EtlBase
  SHEET_INDEX = 0
  SKIP_ROWS = 6

  ATTRIBUTE_MAPPINGS = ActiveSupport::ConfigurationFile.new(
    Rails.root.join('etl/projects/attribute_mappings.yml')
  ).parse.with_indifferent_access.freeze

  # Imports projects from the excel.
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

  def import(current_user, sheet) # rubocop:disable Metrics/SeliseMethodLength
    super do
      Kiba.parse do
        source EtlSource, sheet: sheet

        errors = []
        transform Projects::TransformProject, errors

        transform Projects::TransformAddressBook, :investor
        transform Projects::TransformAddressBook, :architect
        transform Projects::TransformAddressBook, :role_type_3
        transform Projects::TransformAddressBook, :role_type_4

        destination Projects::Destination, errors

        post_process do
          ProjectMailer.notify_import(current_user, errors).deliver_later if errors.present?
        end
      end
    end
  end
end
