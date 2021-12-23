# frozen_string_literal: true

module Projects
  class PctCost < ApplicationRecord
    belongs_to :connection_cost, class_name: 'Projects::ConnectionCost'

    delegate :name, to: :project, prefix: true
  end
end
