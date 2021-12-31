# frozen_string_literal: true

module Projects
  module PctCostHelper
    delegate(
      :ftth_payback_in_years,
      :hfc_payback_in_years,
      :ftth_cost,
      :hfc_cost,
      :mrc_sfn,
      :mrc_standard,
      :iru_sfn,
      :cpe_ftth,
      :cpe_hfc,
      :olt_cost_per_customer,
      :olt_cost_per_unit,
      :patching_cost,
      :mrc_high_tiers,
      :high_tiers_product_share,
      :high_tiers_product_share_percentage,
      to: :admin_toolkit_project_cost
    )

    delegate :zip, to: :project

    attr_accessor :project

    def call
      yield if block_given?
    rescue TypeError
      raise TypeError, I18n.t('admin_toolkit.project_cost.null_fields')
    end

    def admin_toolkit_project_cost
      @_admin_toolkit_project_cost ||= AdminToolkit::ProjectCost.instance
    end

    def customers_count
      @_customers_count ||= apartments_count * penetration_rate
    end

    def apartments_count
      @_apartments_count ||= project.apartments_count.to_i
    end

    def penetration_rate
      @_penetration_rate ||= AdminToolkit::Penetration.find_by!(zip: zip).rate
    rescue ActiveRecord::RecordNotFound
      raise I18n.t('admin_toolkit.penetration.zip_missing')
    end
  end
end
