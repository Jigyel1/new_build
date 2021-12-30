# frozen_string_literal: true

module AdminToolkit
  class ProjectCost < ApplicationRecord
    include Singleton
    public_class_method :allocate

    validates :index, presence: true, uniqueness: true, inclusion: { in: [0] }

    alias_attribute :standard_connection_cost, :standard
    alias_attribute :hfc_cost, :standard

    def self.instance
      find_or_create_by!(index: 0)
    end

    def ftth_payback_in_years
      ftth_payback / MONTHS_IN_A_YEAR
    end

    def hfc_payback_in_years
      hfc_payback / MONTHS_IN_A_YEAR
    end

    def high_tiers_product_share_percentage
      high_tiers_product_share / PERCENTAGE_DIVISOR
    end
  end
end
