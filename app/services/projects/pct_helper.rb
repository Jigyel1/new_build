# frozen_string_literal: true

module Projects
  module PctHelper
    private

    def admin_toolkit_pct(year, cost)
      AdminToolkit::PctValue
        .joins(:pct_cost, :pct_month)
        .where(
          Arel.sql(
            'admin_toolkit_pct_months.min <= :value AND admin_toolkit_pct_months.max >= :value'
          ), value: year
        )
        .find_by(
          Arel.sql(
            'admin_toolkit_pct_costs.min <= :value AND admin_toolkit_pct_costs.max >= :value'
          ), value: cost
        )
    end

    def specify_pct_value
      return admin_toolkit_pct(hfc_pct_cost.payback_period, hfc_pct_cost.build_cost) if project.hfc?
      return admin_toolkit_pct(ftth_pct_cost.payback_period, ftth_pct_cost.build_cost) if project.ftth?

      admin_toolkit_pct(lease_period, max_build_cost)
    end

    def specify_pct_cost
      return hfc_pct_cost if project.hfc?
      return ftth_pct_cost if project.ftth?

      max_pct_build
    end

    def max_pct_build
      hfc_pct_cost.build_cost > ftth_pct_cost.build_cost ? hfc_pct_cost : ftth_pct_cost
    end

    def max_build_cost
      hfc_pct_cost.build_cost > ftth_pct_cost.build_cost ? hfc_pct_cost.build_cost : ftth_pct_cost.build_cost
    end

    def lease_period
      hfc_pct_cost.build_cost == max_build_cost ? hfc_pct_cost.payback_period : ftth_pct_cost.payback_period
    end

    def hfc_pct_cost
      return if project.connection_costs.hfc[0].nil?

      Projects::PctCost.find_by(connection_cost_id: project.connection_costs.hfc[0].id)
    end

    def ftth_pct_cost
      return if project.connection_costs.ftth[0].nil?

      Projects::PctCost.find_by(connection_cost_id: project.connection_costs.ftth[0].id)
    end

    def hfc_cost_type
      return if project.connection_costs.hfc[0].nil?

      project.connection_costs.hfc[0].cost_type
    end

    def ftth_cost_type
      return if project.connection_costs.ftth[0].nil?

      project.connection_costs.ftth[0].cost_type
    end

    def cost_type
      Projects::PctConditionChecker.new(ftth_cost_type, hfc_cost_type, 'standard', 'non_standard')
    end

    def hfc_too_expensive?
      (hfc_cost_type == 'too_expensive' && ftth_cost_type == 'standard') || ftth_cost_type == 'non_standard'
    end

    def ftth_too_expensive?
      (ftth_cost_type == 'too_expensive' && hfc_cost_type == 'standard') || hfc_cost_type == 'non_standard'
    end
  end
end
