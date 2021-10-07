# frozen_string_literal: true

module Types
  module AdminToolkit
    class FootprintApartmentType < BaseObject
      field :id, ID, null: true
      field :index, Int, null: true
      field :min, Int, null: true
      field :max, Int, null: true
    end
  end
end
