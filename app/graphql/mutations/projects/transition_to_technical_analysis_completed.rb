# frozen_string_literal: true

module Mutations
  module Projects
    class TransitionToTechnicalAnalysisCompleted < BaseMutation
      class PctCostAttributes < Types::BaseInputObject
        argument :project_connection_cost, Float, required: false, description: <<~DESC
          Required only for complex projects. 
          Irrelevant for standard projects.
          Optional for irrelevant and marketing only projects.
        DESC
      end

      class InstallationDetailAttributes < Types::BaseInputObject
        argument :sockets, Int, required: true
        argument :builder, String, required: true
      end

      class AccessTechCostAttributes < Types::BaseInputObject
        argument :hfc_on_premise_cost, Float, required: true
        argument :hfc_off_premise_cost, Float, required: true
        argument :lwl_on_premise_cost, Float, required: true
        argument :lwl_off_premise_cost, Float, required: true

        argument :comment, String, required: false
        argument :explanation, String, required: false
      end

      class TransitionToTechnicalAnalysisCompletedAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :category, String, required: true

        argument :standard_cost_applicable, Boolean, required: true
        argument :access_technology, String, required: true
        argument :access_tech_cost, AccessTechCostAttributes, required: false, as: :access_tech_cost_attributes

        argument :competition_id, String, required: true
        argument :construction_type, String, required: true
        argument :customer_request, Boolean, required: true

        argument :in_house_installation, Boolean, required: true
        argument :installation_detail, InstallationDetailAttributes, required: false, as: :installation_detail_attributes

        argument :priority, String, required: true
        argument :analysis, String, required: false

        argument :pct_cost, PctCostAttributes, required: false, as: :pct_cost_attributes
      end

      argument :attributes, TransitionToTechnicalAnalysisCompletedAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        resolver = ::Projects::StatusUpdater.new(
          current_user: current_user,
          attributes: attributes.to_h,
          event: :technical_analysis_completed
        )

        resolver.call
        { project: resolver.project }
      end
    end
  end
end
