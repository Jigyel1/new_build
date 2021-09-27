# frozen_string_literal: true

module Mutations
  class ExportProjects < BaseMutation
    argument :ids, [ID], required: true
    field :url, String, null: true

    # from the IDs, create excel/csv, then send url of that file to FE.
    def resolve(ids:)
      { url: ::Projects::Exporter.new(current_user: current_user, ids: ids).call }
    end
  end
end
