# frozen_string_literal: true

module Projects
  class AccessTechCost < ApplicationRecord
    belongs_to :project

    validates :hfc_on_premise_cost, :hfc_off_premise_cost, :lwl_on_premise_cost, :lwl_off_premise_cost, presence: true
  end
end
