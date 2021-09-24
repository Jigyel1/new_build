# frozen_string_literal: true

module Projects
  class PctCost < ApplicationRecord
    belongs_to :project
  end
end
