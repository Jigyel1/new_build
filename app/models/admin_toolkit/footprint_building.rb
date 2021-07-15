# frozen_string_literal: true

module AdminToolkit
  class FootprintBuilding < ApplicationRecord
    validates :min, :max, numericality: { greater_than: 0 }
    validates :max, numericality: { greater_than_or_equal_to: :min }
    validates :index, uniqueness: true
  end
end
