# frozen_string_literal: true

module Types
  module Projects
    class FileConnectionType < BaseConnectionType
      edge_type(Types::Projects::FileEdgeType)
    end
  end
end
