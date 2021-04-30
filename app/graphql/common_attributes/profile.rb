# frozen_string_literal: true

module CommonAttributes
  module Profile
    extend ActiveSupport::Concern

    included do
      graphql_name 'CommonAttributesProfile'

      argument :id, GraphQL::Types::ID, required: false
      argument :salutation, String, required: false
      argument :firstname, String, required: false
      argument :lastname, String, required: false
      argument :phone, String, required: false
      argument :department, String, required: false
    end
  end
end
