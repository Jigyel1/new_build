# frozen_string_literal: true

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    include GraphqlHelper

    def empty?(collection)
      collection.reject(&:empty?).empty?
    end
  end
end
