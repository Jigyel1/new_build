# frozen_string_literal: true

module Projects
  class ContractSummaryPdfCreator < BaseService
    attr_accessor :project_id

    def call
      current_user.contract_pdf_download.attach(
        io: StringIO.new(Pdf::PdfGenerator.new(id: project_id).generate),
        filename: "contract_summary(#{Time.current.strftime('%d/%m/%Y %H:%M:%S')}).pdf",
        content_type: 'application/pdf'
      ).then do |attached|
        attached && url_for(current_user.contract_pdf_download)
      end
    end
  end
end
