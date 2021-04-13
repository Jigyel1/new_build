# frozen_string_literal: true

require 'search_object/plugin/graphql'

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    include SearchObject.module(:graphql)
    # include GraphqlHelper
    # include Pagination
    # include Pundit

    def empty?(collection)
      collection.reject(&:empty?).empty?
    end
  end
end
