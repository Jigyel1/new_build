# frozen_string_literal: true

module AdminToolkit
  class ProjectCost < ApplicationRecord
    include Singleton
    public_class_method :allocate

    validates :index, presence: true, uniqueness: true, inclusion: { in: [0] }

    alias_attribute :standard_connection_cost, :standard
    alias_attribute :ftth_standard, :ftth_cost

    def self.instance
      find_or_create_by!(index: 0)
    end

    def high_tiers_product_share_percentage
      high_tiers_product_share / PERCENTAGE_DIVISOR
    end
  end
end
