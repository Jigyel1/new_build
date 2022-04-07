# frozen_string_literal: true

module Pdf
  module Helpers
    include ActionView::Helpers::TextHelper

    def body_layout
      render_to_string(
        'pdf/project_summary.html.erb',
        layout: 'project_pdf',
        locals: locals
      )
    end

    def locals # rubocop:disable Metrics/AbcSize
      {
        project: project.decorate,
        analysis: strip_html_tags(project.analysis),
        hfc_payback_in_years: hfc_payback,
        ftth_payback_in_years: ftth_payback,
        hfc_pct_cost: hfc_pct_cost,
        ftth_pct_cost: ftth_pct_cost,
        hfc_payback: hfc_pct_cost.present? ? payback(hfc_pct_cost) : nil,
        ftth_payback: ftth_pct_cost.present? ? payback(ftth_pct_cost) : nil
      }
    end

    def options
      {
        orientation: 'Portrait',
        page_size: 'A4',
        dpi: 96,
        lowquality: false,
        image_quality: 500,
        viewport_size: '1280x1024',
        margin: { right: 10, left: 10, top: 19, bottom: 30 },
        encoding: 'utf-8'
      }
    end

    def hfc_pct_cost
      return if project.connection_costs.hfc[0].nil?

      Projects::PctCost.find_by(connection_cost_id: project.connection_costs.hfc[0].id)
    end

    def ftth_pct_cost
      return if project.connection_costs.ftth[0].nil?

      Projects::PctCost.find_by(connection_cost_id: project.connection_costs.ftth[0].id)
    end

    def strip_html_tags(string)
      ActionView::Base.full_sanitizer.sanitize(string)
    end

    def payback(cost)
      years = cost.payback_period.round(2)

      I18n.t('projects.payback_period.years', years: years)
    end

    def hfc_payback
      AdminToolkit::ProjectCost.first.hfc_payback
    end

    def ftth_payback
      AdminToolkit::ProjectCost.first.ftth_payback
    end
  end
end
