class Penetration < EtlBase
  SHEET_INDEX = 0

  def call(pathname:)
    sheet = Xsv::Workbook.open(pathname.to_s).sheets[0]
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
