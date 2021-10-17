# frozen_string_literal: true

module Projects
  class PctCost < ApplicationRecord
    belongs_to :project

    delegate :name, to: :project
  end
end
