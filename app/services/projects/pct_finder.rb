# frozen_string_literal: true

module Projects
  class PctFinder < BaseService
    attr_accessor :project, :type

    include PctHelper

    def call
      send(type)
    end

    private

    def pct_value
      if project.standard?
        admin_toolkit_pct(hfc_pct_cost.payback_period, hfc_pct_cost.build_cost)
      else
        pct_status
      end
    end

    def pct_cost
      if project.standard?
        hfc_pct_cost
      else
        return specify_pct_cost if cost_type.valid_combination?
        return ftth_pct_cost if hfc_too_expensive?

        hfc_pct_cost if ftth_too_expensive?
      end
    end

    def pct_status
      return specify_pct_value if cost_type.valid_combination?
      return admin_toolkit_pct(ftth_pct_cost.payback_period, ftth_pct_cost.build_cost) if hfc_too_expensive?

      admin_toolkit_pct(hfc_pct_cost.payback_period, hfc_pct_cost.build_cost) if ftth_too_expensive?
    end
  end
end
