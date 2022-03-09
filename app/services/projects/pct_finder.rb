# frozen_string_literal: true

module Projects
  class PctFinder < BaseService
    attr_accessor :type, :id

    include PctHelper

    def call
      send(type)
    end

    private

    def pct_value # rubocop:disable Metrics/AbcSize
      unless project.standard?
        return specify_pct_value if cost_type.valid_combination?
        return admin_toolkit_pct(ftth_pct_cost.payback_period, ftth_pct_cost.build_cost) if hfc_too_expensive
        return admin_toolkit_pct(hfc_pct_cost.payback_period, hfc_pct_cost.build_cost) if ftth_too_expensive
      end

      admin_toolkit_pct(hfc_pct_cost.payback_period, hfc_pct_cost.build_cost) if project.standard?
    end

    def pct_cost
      unless project.standard?
        return specify_pct_cost if cost_type.valid_combination?
        return ftth_pct_cost if hfc_too_expensive
        return hfc_pct_cost if ftth_too_expensive
      end

      hfc_pct_cost if project.standard?
    end

    def project
      @project ||= Project.find(id)
    end
  end
end
