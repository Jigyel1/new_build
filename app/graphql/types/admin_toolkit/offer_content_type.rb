# frozen_string_literal: true

module Types
  module AdminToolkit
    class OfferContentType < BaseObject
      field :id, ID, null: true
      field :title, GraphQL::Types::JSON, null: true
      field :content, GraphQL::Types::JSON, null: true
    end
  end
end
