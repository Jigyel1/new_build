# frozen_string_literal: true

module Projects
  class ConnectionCost < ApplicationRecord
    belongs_to :project

    validates :connection_type, :value, presence: true
  end
end
