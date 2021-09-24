# frozen_string_literal: true

module Types
  module Projects
    class AccessTechCostType < BaseObject
      field :id, ID, null: true
      field :hfc_on_premise_cost, Float, null: true
      field :hfc_off_premise_cost, Float, null: true
      field :lwl_on_premise_cost, Float, null: true
      field :lwl_off_premise_cost, Float, null: true
      field :comment, String, null: true
      field :explanation, String, null: true
    end
  end
end
