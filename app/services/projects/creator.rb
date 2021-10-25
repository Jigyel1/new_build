# frozen_string_literal: true

module Projects
  class Creator < BaseService
    attr_reader :project
    attr_accessor :buildings_count, :apartments_count

    def initialize(params = {})
      @buildings_count = params[:attributes].delete(:buildings_count)
      @apartments_count = params[:attributes].delete(:apartments_count)

      super
    end

    def call
      authorize! Project, to: :create?

      with_tracking(activity_id = SecureRandom.uuid) do
        @project = ::Project.new(formatted_attributes)
        build_associations

        # set category only after building associations for the project.
        project.category = CategorySetter.new(project: project).call
        project.save!

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def formatted_attributes
      attributes[:address_books_attributes].each { |attr| attr[:entry_type] = :manual }
      attributes
    end

    def build_associations
      project.assignee_type = :nbo if project.assignee.try(:nbo_team?)

      BuildingsBuilder.new(project: project, buildings_count: buildings_count, apartments_count: apartments_count).call
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_created,
        owner: current_user,
        trackable: project,
        parameters: { entry_type: project.entry_type, project_name: project.name }
      }
    end
  end
end
