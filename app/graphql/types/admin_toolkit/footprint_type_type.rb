# frozen_string_literal: true

module Types
  module AdminToolkit
    class FootprintTypeType < BaseObject
      field :id, ID, null: true
      field :index, Int, null: true
      field :provider, String, null: true
    end
  end
end
