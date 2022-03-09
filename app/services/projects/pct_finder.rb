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
      if project.standard?
        admin_toolkit_pct(hfc_pct_cost.payback_period, hfc_pct_cost.build_cost) if project.standard?
      else
        specify_pct_value if cost_type.valid_combination?
        admin_toolkit_pct(ftth_pct_cost.payback_period, ftth_pct_cost.build_cost) if hfc_too_expensive
        admin_toolkit_pct(hfc_pct_cost.payback_period, hfc_pct_cost.build_cost) if ftth_too_expensive
      end
    end

    def pct_cost
      if project.standard?
        hfc_pct_cost if project.standard?
      else
        specify_pct_cost if cost_type.valid_combination?
        ftth_pct_cost if hfc_too_expensive
        hfc_pct_cost if ftth_too_expensive
      end
    end

    def project
      @_project ||= Project.find(id)
    end
  end
end
