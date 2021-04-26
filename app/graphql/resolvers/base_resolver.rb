# frozen_string_literal: true

module Resolvers
  class BaseResolver < GraphQL::Schema::Resolver
    include ActionPolicy::GraphQL::Behaviour
    include GraphqlHelper
    extend Forwardable

    def_delegator ActiveSupport::Notifications, :instrument

    def empty?(collection)
      collection.reject(&:empty?).empty?
    end
  end
end
