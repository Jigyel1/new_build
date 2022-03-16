# frozen_string_literal: true

module Pdf
  class PdfGenerator
    include Pdf::Helpers

    attr_accessor :project

    def initialize(id:)
      @project = Project.find(id)
    end

    def generate
      WickedPdf.new.pdf_from_string(body_layout, options)
    end

    private

    def render_to_string(*args)
      ActionController::Base.new.render_to_string(*args)
    end
  end
end
