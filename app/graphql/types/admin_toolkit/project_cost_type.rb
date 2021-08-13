# frozen_string_literal: true

module Types
  module AdminToolkit
    class ProjectCostType < BaseObject
      field :id, ID, null: true
      field :standard, Float, null: true
      field :arpu, Float, null: true
      field :socket_installation_rate, Float, null: true
    end
  end
end
