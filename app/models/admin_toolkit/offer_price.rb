# frozen_string_literal: true

module AdminToolkit
  class OfferPrice < ApplicationRecord
    validates :min_apartments, :max_apartments, :name, :value, presence: true
    validates :min_apartments, :max_apartments, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :max_apartments, numericality: { greater_than_or_equal_to: :min_apartments }
  end
end
