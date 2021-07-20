# frozen_string_literal: true

module AdminToolkit
  class Competition < ApplicationRecord
    validates :name, :factor, :lease_rate, presence: true
    validates :name, uniqueness: { case_sensitive: false }
    validates :factor, numericality: { greater_than_or_equal_to: 0 }
  end
end
