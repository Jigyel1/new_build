# frozen_string_literal: true

module Types
  module AdminToolkit
    class KamInvestorType < BaseObject
      field :id, ID, null: true
      field :kam, Types::UserType, null: true
      field :investor_id, String, null: true
      field :investor_description, String, null: true
    end
  end
end
