# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    include GraphqlHelper

    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def resolve(klass, key, attributes:)
      resolver = klass.new(current_user: current_user, attributes: attributes.to_h)
      resolver.call
      { "#{key}": resolver.public_send(key) }
    end
  end
end
