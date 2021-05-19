# frozen_string_literal: true

module Types
  class ActivityQueryType < Types::BaseInputObject
    argument :user_ids, [String], required: false
    argument :actions, [String], required: false
    argument :dates, [String], required: false
    argument :query, String, required: false
  end
end
