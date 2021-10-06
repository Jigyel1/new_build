# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    using TimeFormatter
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField

    include GraphqlHelper
    include Rails.application.routes.url_helpers

    def in_time_zone(method, format: :date_str)
      return unless object.send(method)

      object.send(method).send(format)
    end

    protected

    def preload_association(association)
      BatchLoaders::AssociationLoader
        .for(object.class, association)
        .load(object)
    end
  end
end
