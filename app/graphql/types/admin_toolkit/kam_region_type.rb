# frozen_string_literal: true

module Types
  module AdminToolkit
    class KamRegionType < BaseObject
      field :id, ID, null: true
      field :name, String, null: true
      field :kam, UserType, null: true
    end
  end
end
