# frozen_string_literal: true

module Types
  module AdminToolkit
    class CompetitionType < BaseObject
      field :id, ID, null: true
      field :name, String, null: true
      field :sfn, Boolean, null: true
      field :factor, Float, null: true
      field :lease_rate, String, null: true
      field :description, String, null: true
    end
  end
end
