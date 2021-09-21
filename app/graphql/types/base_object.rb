# frozen_string_literal: true

module Types
  class BaseObject < GraphQL::Schema::Object
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField

    include GraphqlHelper

    protected

    def preload_association(association)
      BatchLoaders::AssociationLoader
        .for(object.class, association)
        .load(object)
    end
  end
end
