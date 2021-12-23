# frozen_string_literal: true

module AdminToolkit
  class OfferAdditionalCost < ApplicationRecord
    validates :name, :value, :additional_cost_type, presence: true
    validates :value, numericality: { greater_than_or_equal_to: 0 }, if: :addition?
    validates :value, numericality: { less_than: 0 }, if: :discount?

    enum additional_cost_type: {
      discount: 'Discount',
      addition: 'Addition'
    }
  end
end
