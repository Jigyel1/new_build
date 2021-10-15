# frozen_string_literal: true

module Types
  module Projects
    class FileEdgeType < GraphQL::Types::Relay::BaseEdge
      node_type(Types::Projects::FileType)
    end
  end
end
