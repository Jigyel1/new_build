# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    using TimeFormatter
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField

    include GraphqlHelper
    include Rails.application.routes.url_helpers

    def in_time_zone(method)
      return unless object.send(method)

      object.send(method).in_time_zone(context[:time_zone]).date_str
    end
  end
end
