# frozen_string_literal: true

module Projects
  class ConnectionCost < ApplicationRecord
    belongs_to :project

    validates :connection_type, :standard_cost, :value, presence: true
  end
end
