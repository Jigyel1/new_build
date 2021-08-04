# frozen_string_literal: true

class ProjectImporter
  SHEET_INDEX = 0

  def self.call(pathname:)
    new.call(pathname: pathname)
  end

  def call(pathname:)
    sheet = Xsv::Workbook.open(pathname.to_s).sheets[SHEET_INDEX]
    sheet.row_skip = 4
    sheet.parse_headers!

    Kiba.run(
      Kiba.parse do
        source Projects::Source, sheet: sheet
        transform Projects::Transform
        destination Projects::Destination
      end
    )
  end
end
