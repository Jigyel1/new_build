# frozen_string_literal: true

module Mutations
  module Projects
    class ContractSummaryPdfGenerator < BaseMutation
      argument :project_id, ID, required: true
      field :url, String, null: true

      # from the IDs, create pdf, then send url of that file to FE.
      def resolve(project_id:)
        { url: ::Projects::ContractSummaryPdfCreator.new(current_user: current_user, project_id: project_id).call }
      end
    end
  end
end
