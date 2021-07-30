# frozen_string_literal: true

module Types
  module AdminToolkit
    class ProjectCostType < BaseObject
      field :id, ID, null: true
      field :standard, String, null: true
      field :arpu, String, null: true
    end
  end
end
