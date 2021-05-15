# frozen_string_literal: true

module Types
  class ActivityQueryType < Types::BaseInputObject
    argument :emails, [String], required: false
    argument :dates, [String], required: false
    argument :query, String, required: false
  end
end
