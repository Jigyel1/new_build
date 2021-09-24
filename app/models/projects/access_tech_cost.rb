# frozen_string_literal: true

module Projects
  class AccessTechCost < ApplicationRecord
    belongs_to :project
  end
end
