# frozen_string_literal: true

module Mutations
  module Projects
    class ExportBuilding < BaseMutation
      argument :id, ID, required: true
      field :url, String, null: true

      # from the IDs, create excel/csv, then send url of that file to FE.
      def resolve(id:)
        { url: ::Projects::BuildingExporter.new(current_user: current_user, id: id).call }
      end
    end
  end
end
