# frozen_string_literal: true

class Penetration
  SHEET_INDEX = 0

  def self.call(pathname:)
    new.call(pathname: pathname)
  end

  def call(pathname:)
    sheet = Xsv::Workbook.open(pathname.to_s).sheets[SHEET_INDEX]
    sheet.row_skip = 1

    Kiba.run(
      Kiba.parse do
        source Penetrations::Source, sheet: sheet
        transform Penetrations::Transform
        destination Penetrations::Destination
      end
    )
  end
end
